const http = require('http')
const exec = require("child_process").exec
const crypto = require("crypto")

const secret = process.env.WEBHOOK_SECRET

http.createServer(function(request, response) {
    request.on('data', function(chunk) {
        let sig = "sha1=" + crypto.createHmac('sha1', secret).update(chunk.toString()).digest('hex');
        if (crypto.timingSafeEqual(Buffer.from(request.headers['x-hub-signature']), Buffer.from(sig))) {
            exec(
                "/home/ec2-user/multinet-deploy/check-for-updates.sh"
            )
        }
        response.writeHead(200, { 'Content-type': 'text/json' });
        response.write('Successful run');
        response.end();
    })



}).listen(4112);