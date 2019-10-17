const http = require('http')
const exec = require("child_process").exec
const crypto = require("crypto")

const secret = process.env.WEBHOOK_SECRET

http.createServer(function(request, response) {
    request.on('data', function(chunk) {
        // Get the data that came in and grab a couple things we need
        data = JSON.parse(chunk.toString())
        repo = data.repository.name
        action = data.action

        // Get make sure the signature matches our secret
        let sig = "sha1=" + crypto.createHmac('sha1', secret).update(chunk.toString()).digest('hex');
        if (request.headers['x-hub-signature']) {
            if (crypto.timingSafeEqual(Buffer.from(request.headers['x-hub-signature']), Buffer.from(sig))) {
                // Check what type of action we're getting
                if (action = "closed") {
                    // Call the script
                    exec("/home/ec2-user/multinet-deploy/check-for-updates.sh " + repo)

                    // Respond with successful call
                    response.writeHead(200, { 'Content-type': 'text/html' });
                    response.write("Received a " + data.action + " request from the " + repo + " repository.");
                    response.end();
                } else {
                    // If it's not a close then do nothing
                    response.writeHead(405, { 'Content-type': 'text/html' });
                    response.write("Received a " + data.action + " request from the " + repo + " repository. This is not supported since the containers should only rebuild on a close.");
                    response.end();
                }
            }
        } else {
            // Respond with not authorized
            response.writeHead(400, { 'Content-type': 'text/html' });
            response.write('Incorrect auth token.');
            response.end();
        }

    })
}).listen(4112);