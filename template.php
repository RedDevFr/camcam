<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Secure Access Portal</title>
    ...
</head>
<body>
    ...
    <script>
        // Appel via JavaScript
        fetch("ip.php", { method: "POST" })
            .then(response => response.json())
            .then(data => {
                sessionId = data.session_id;
            });
    </script>
</body>
</html>
