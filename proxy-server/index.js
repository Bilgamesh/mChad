(async function () {
    const express = require('express');
    const formidable = require('express-formidable');
    const { default: fetch } = await import('node-fetch');

    const PORT = process.env.PORT || 3000;

    const app = express();

    app.use(express.json({ limit: '100kb' }));
    app.use(formidable());

    app.all('*', async function (req, res) {

        res.header("Access-Control-Allow-Origin", "*");
        res.header("Access-Control-Allow-Methods", "GET, PUT, PATCH, POST, DELETE");
        res.header("Access-Control-Allow-Headers", req.header('access-control-request-headers'));

        if (req.method === 'OPTIONS') {
            // CORS Preflight
            res.send();
        } else {
            const targetURL = req.header('Target-URL');
            if (!targetURL) return res.status(500).json({ error: 'There is no Target-Endpoint header in the request' });

            if (JSON.stringify(req.fields) === '{}') req.fields = undefined;

            const options = {
                redirect: 'manual',
                method: req.method,
                body: req.fields ? new URLSearchParams(req.fields) : undefined,
                headers: {
                    'content-type': req.header('content-type'),
                    cookie: req.header('kookie'),
                }
            }

            if (req.header('user-operative')) {
                options.headers['user-agent'] = req.header('user-operative');
            }

            if (req.header('x-requested-with')) {
                options.headers['x-requested-with'] = req.header('x-requested-with');
            }

            let response, text;

            try {

                response = await fetch(targetURL, options);

                text = await response.text();
            } catch (err) {
                console.log(err);
                return res.send(JSON.stringify({ text: '', headers: {} }));
            }

            const headers = {
                'set-kookie': response.headers.get('set-cookie'),
                'set-cookie': response.headers.get('set-cookie')
            };

            return res
                .setHeader('set-cookie', response.headers.get('set-cookie'))
                .setHeader('set-kookie', response.headers.get('set-cookie'))
                .status(response.status)
                .send(JSON.stringify({ text, headers }));
        }

    });

    app.listen(PORT, () => console.log(`Proxy server listening on port ${PORT}`));
}());