// Enhanced Device Fingerprinting Module
// Collects comprehensive device and browser information

class DeviceFingerprint {
    constructor() {
        this.fingerprint = {};
        this.sessionId = null;
    }

    // Initialize and collect all fingerprint data
    async collect() {
        try {
            this.fingerprint = {
                id: this.generateFingerprint(),
                timestamp: new Date().toISOString(),
                basic: this.getBasicInfo(),
                screen: this.getScreenInfo(),
                browser: this.getBrowserInfo(),
                hardware: await this.getHardwareInfo(),
                network: await this.getNetworkInfo(),
                media: await this.getMediaDevices(),
                features: this.getFeatureDetection(),
                canvas: this.getCanvasFingerprint(),
                webgl: this.getWebGLFingerprint(),
                audio: await this.getAudioFingerprint(),
                fonts: this.getFontFingerprint(),
                plugins: this.getPlugins(),
                timezone: this.getTimezoneInfo(),
                battery: await this.getBatteryInfo(),
                confidence: 0
            };

            this.fingerprint.confidence = this.calculateConfidence();
            return this.fingerprint;
        } catch (error) {
            console.error('Fingerprint collection error:', error);
            return null;
        }
    }

    // Generate unique fingerprint ID
    generateFingerprint() {
        const components = [
            navigator.userAgent,
            navigator.language,
            screen.colorDepth,
            screen.width + 'x' + screen.height,
            new Date().getTimezoneOffset(),
            !!window.sessionStorage,
            !!window.localStorage
        ];
        
        const str = components.join('###');
        return this.hashCode(str);
    }

    hashCode(str) {
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash;
        }
        return Math.abs(hash).toString(36);
    }

    // Basic device information
    getBasicInfo() {
        return {
            user_agent: navigator.userAgent,
            platform: navigator.platform,
            language: navigator.language,
            languages: navigator.languages || [navigator.language],
            online: navigator.onLine,
            cookie_enabled: navigator.cookieEnabled,
            do_not_track: navigator.doNotTrack || 'unspecified',
            max_touch_points: navigator.maxTouchPoints || 0
        };
    }

    // Screen information
    getScreenInfo() {
        return {
            width: screen.width,
            height: screen.height,
            available_width: screen.availWidth,
            available_height: screen.availHeight,
            color_depth: screen.colorDepth,
            pixel_depth: screen.pixelDepth,
            orientation: screen.orientation ? screen.orientation.type : 'unknown',
            device_pixel_ratio: window.devicePixelRatio || 1,
            inner_width: window.innerWidth,
            inner_height: window.innerHeight,
            outer_width: window.outerWidth,
            outer_height: window.outerHeight
        };
    }

    // Browser information
    getBrowserInfo() {
        const ua = navigator.userAgent;
        let browser = 'Unknown';
        let version = 'Unknown';
        let engine = 'Unknown';

        // Detect browser
        if (ua.indexOf('Edge') > -1 || ua.indexOf('Edg') > -1) {
            browser = 'Microsoft Edge';
            version = ua.match(/Edg\/(\d+)/)?.[1] || 'Unknown';
        } else if (ua.indexOf('Chrome') > -1 && ua.indexOf('Edg') === -1) {
            browser = 'Google Chrome';
            version = ua.match(/Chrome\/(\d+)/)?.[1] || 'Unknown';
        } else if (ua.indexOf('Safari') > -1 && ua.indexOf('Chrome') === -1) {
            browser = 'Safari';
            version = ua.match(/Version\/(\d+)/)?.[1] || 'Unknown';
        } else if (ua.indexOf('Firefox') > -1) {
            browser = 'Firefox';
            version = ua.match(/Firefox\/(\d+)/)?.[1] || 'Unknown';
        } else if (ua.indexOf('Opera') > -1 || ua.indexOf('OPR') > -1) {
            browser = 'Opera';
            version = ua.match(/OPR\/(\d+)/)?.[1] || 'Unknown';
        }

        // Detect rendering engine
        if (ua.indexOf('Gecko') > -1) engine = 'Gecko';
        else if (ua.indexOf('WebKit') > -1) engine = 'WebKit';
        else if (ua.indexOf('Trident') > -1) engine = 'Trident';
        else if (ua.indexOf('Presto') > -1) engine = 'Presto';

        return {
            name: browser,
            version: version,
            engine: engine,
            vendor: navigator.vendor || 'Unknown',
            app_name: navigator.appName,
            app_version: navigator.appVersion,
            app_code_name: navigator.appCodeName,
            product: navigator.product || 'Unknown',
            product_sub: navigator.productSub || 'Unknown',
            build_id: navigator.buildID || 'Unknown'
        };
    }

    // Hardware information
    async getHardwareInfo() {
        return {
            cpu_cores: navigator.hardwareConcurrency || 'Unknown',
            device_memory: navigator.deviceMemory || 'Unknown',
            max_touch_points: navigator.maxTouchPoints || 0,
            pointer_type: this.getPointerType(),
            mobile: /Mobile|Android|iPhone|iPad|iPod/i.test(navigator.userAgent)
        };
    }

    getPointerType() {
        if (window.PointerEvent) {
            if (navigator.maxTouchPoints > 0) return 'touch';
            return 'mouse';
        }
        return 'unknown';
    }

    // Network information
    async getNetworkInfo() {
        const connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
        
        if (connection) {
            return {
                effective_type: connection.effectiveType || 'Unknown',
                downlink: connection.downlink || 'Unknown',
                rtt: connection.rtt || 'Unknown',
                save_data: connection.saveData || false,
                type: connection.type || 'Unknown'
            };
        }
        
        return { status: 'Not supported' };
    }

    // Media devices
    async getMediaDevices() {
        if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
            return { status: 'Not supported' };
        }

        try {
            const devices = await navigator.mediaDevices.enumerateDevices();
            return {
                audio_input: devices.filter(d => d.kind === 'audioinput').length,
                audio_output: devices.filter(d => d.kind === 'audiooutput').length,
                video_input: devices.filter(d => d.kind === 'videoinput').length,
                total: devices.length
            };
        } catch (error) {
            return { error: 'Permission denied' };
        }
    }

    // Feature detection
    getFeatureDetection() {
        return {
            local_storage: !!window.localStorage,
            session_storage: !!window.sessionStorage,
            indexed_db: !!window.indexedDB,
            web_sql: !!window.openDatabase,
            geolocation: !!navigator.geolocation,
            service_worker: 'serviceWorker' in navigator,
            web_rtc: !!(navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia),
            web_gl: !!window.WebGLRenderingContext,
            canvas: !!document.createElement('canvas').getContext,
            web_assembly: typeof WebAssembly === 'object',
            notifications: 'Notification' in window,
            push_manager: 'PushManager' in window,
            bluetooth: 'bluetooth' in navigator,
            usb: 'usb' in navigator,
            vibrate: 'vibrate' in navigator
        };
    }

    // Canvas fingerprinting
    getCanvasFingerprint() {
        try {
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            
            canvas.width = 200;
            canvas.height = 50;
            
            ctx.textBaseline = 'top';
            ctx.font = '14px Arial';
            ctx.textBaseline = 'alphabetic';
            ctx.fillStyle = '#f60';
            ctx.fillRect(125, 1, 62, 20);
            ctx.fillStyle = '#069';
            ctx.fillText('Device Fingerprint 🔒', 2, 15);
            ctx.fillStyle = 'rgba(102, 204, 0, 0.7)';
            ctx.fillText('Device Fingerprint 🔒', 4, 17);
            
            return {
                hash: this.hashCode(canvas.toDataURL()),
                supported: true
            };
        } catch (error) {
            return { error: error.message, supported: false };
        }
    }

    // WebGL fingerprinting
    getWebGLFingerprint() {
        try {
            const canvas = document.createElement('canvas');
            const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
            
            if (!gl) return { supported: false };
            
            const debugInfo = gl.getExtension('WEBGL_debug_renderer_info');
            
            return {
                vendor: debugInfo ? gl.getParameter(debugInfo.UNMASKED_VENDOR_WEBGL) : 'Unknown',
                renderer: debugInfo ? gl.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL) : 'Unknown',
                version: gl.getParameter(gl.VERSION),
                shading_language: gl.getParameter(gl.SHADING_LANGUAGE_VERSION),
                max_texture_size: gl.getParameter(gl.MAX_TEXTURE_SIZE),
                max_vertex_attribs: gl.getParameter(gl.MAX_VERTEX_ATTRIBS),
                max_viewport_dims: gl.getParameter(gl.MAX_VIEWPORT_DIMS),
                supported: true
            };
        } catch (error) {
            return { error: error.message, supported: false };
        }
    }

    // Audio fingerprinting
    async getAudioFingerprint() {
        try {
            if (!window.AudioContext && !window.webkitAudioContext) {
                return { supported: false };
            }

            const AudioContext = window.AudioContext || window.webkitAudioContext;
            const context = new AudioContext();
            const oscillator = context.createOscillator();
            const analyser = context.createAnalyser();
            const gainNode = context.createGain();
            const scriptProcessor = context.createScriptProcessor(4096, 1, 1);

            gainNode.gain.value = 0;
            oscillator.connect(analyser);
            analyser.connect(scriptProcessor);
            scriptProcessor.connect(gainNode);
            gainNode.connect(context.destination);
            oscillator.start(0);

            return new Promise((resolve) => {
                scriptProcessor.onaudioprocess = function(event) {
                    const output = event.outputBuffer.getChannelData(0);
                    const hash = this.hashCode(output.slice(0, 30).join(''));
                    
                    scriptProcessor.disconnect();
                    oscillator.disconnect();
                    analyser.disconnect();
                    gainNode.disconnect();
                    
                    resolve({
                        hash: hash,
                        sample_rate: context.sampleRate,
                        supported: true
                    });
                }.bind(this);
            });
        } catch (error) {
            return { error: error.message, supported: false };
        }
    }

    // Font detection
    getFontFingerprint() {
        const baseFonts = ['monospace', 'sans-serif', 'serif'];
        const testFonts = [
            'Arial', 'Verdana', 'Times New Roman', 'Courier New', 'Georgia',
            'Palatino', 'Garamond', 'Bookman', 'Comic Sans MS', 'Trebuchet MS',
            'Impact', 'Lucida Console', 'Tahoma', 'Helvetica'
        ];
        
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');
        const text = 'mmmmmmmmmmlli';
        const detectedFonts = [];
        
        const baseSizes = {};
        baseFonts.forEach(font => {
            context.font = `72px ${font}`;
            baseSizes[font] = context.measureText(text).width;
        });
        
        testFonts.forEach(font => {
            let detected = false;
            baseFonts.forEach(baseFont => {
                context.font = `72px ${font}, ${baseFont}`;
                const size = context.measureText(text).width;
                if (size !== baseSizes[baseFont]) {
                    detected = true;
                }
            });
            if (detected) {
                detectedFonts.push(font);
            }
        });
        
        return {
            detected: detectedFonts,
            count: detectedFonts.length
        };
    }

    // Plugin detection
    getPlugins() {
        const plugins = [];
        
        if (navigator.plugins && navigator.plugins.length > 0) {
            for (let i = 0; i < navigator.plugins.length; i++) {
                plugins.push({
                    name: navigator.plugins[i].name,
                    description: navigator.plugins[i].description,
                    filename: navigator.plugins[i].filename
                });
            }
        }
        
        return {
            list: plugins,
            count: plugins.length
        };
    }

    // Timezone information
    getTimezoneInfo() {
        const date = new Date();
        return {
            offset: date.getTimezoneOffset(),
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || 'Unknown',
            locale: Intl.DateTimeFormat().resolvedOptions().locale || 'Unknown'
        };
    }

    // Battery information
    async getBatteryInfo() {
        if (!navigator.getBattery) {
            return { supported: false };
        }

        try {
            const battery = await navigator.getBattery();
            return {
                charging: battery.charging,
                level: Math.round(battery.level * 100),
                charging_time: battery.chargingTime,
                discharging_time: battery.dischargingTime,
                supported: true
            };
        } catch (error) {
            return { error: error.message, supported: false };
        }
    }

    // Calculate confidence score
    calculateConfidence() {
        let score = 0;
        const weights = {
            canvas: 15,
            webgl: 15,
            audio: 10,
            fonts: 10,
            screen: 10,
            browser: 10,
            hardware: 10,
            plugins: 5,
            features: 5,
            timezone: 5,
            network: 3,
            battery: 2
        };

        if (this.fingerprint.canvas?.supported) score += weights.canvas;
        if (this.fingerprint.webgl?.supported) score += weights.webgl;
        if (this.fingerprint.audio?.supported) score += weights.audio;
        if (this.fingerprint.fonts?.count > 0) score += weights.fonts;
        if (this.fingerprint.screen) score += weights.screen;
        if (this.fingerprint.browser) score += weights.browser;
        if (this.fingerprint.hardware) score += weights.hardware;
        if (this.fingerprint.plugins?.count >= 0) score += weights.plugins;
        if (this.fingerprint.features) score += weights.features;
        if (this.fingerprint.timezone) score += weights.timezone;
        if (this.fingerprint.network) score += weights.network;
        if (this.fingerprint.battery?.supported) score += weights.battery;

        return score;
    }

    // Send fingerprint to server
    async send(sessionId) {
        this.sessionId = sessionId;
        
        try {
            const response = await fetch('fingerprint.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    session_id: sessionId,
                    fingerprint: this.fingerprint
                })
            });

            const result = await response.json();
            console.log('Fingerprint sent:', result.status);
            return result;
        } catch (error) {
            console.error('Error sending fingerprint:', error);
            return null;
        }
    }
}

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initFingerprint);
} else {
    initFingerprint();
}

async function initFingerprint() {
    try {
        const fingerprinter = new DeviceFingerprint();
        const data = await fingerprinter.collect();
        
        // Wait for session ID from ip.php
        setTimeout(async () => {
            const sessionId = window.sessionStorage?.getItem('session_id');
            if (sessionId && data) {
                await fingerprinter.send(sessionId);
            }
        }, 1000);
    } catch (error) {
        console.error('Fingerprint initialization error:', error);
    }
}