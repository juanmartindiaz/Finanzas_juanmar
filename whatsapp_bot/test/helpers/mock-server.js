import http from 'node:http';

/** Servidor HTTP mock del servidor local de la app. */
export async function crearServidorMock({ puerto = 0 } = {}) {
  const estado = { peticiones: [], respuesta: { status: 201, body: {} } };
  const servidor = http.createServer((req, res) => {
    const trozos = [];
    req.on('data', (trozo) => trozos.push(trozo));
    req.on('end', () => {
      const cuerpo = Buffer.concat(trozos);
      estado.peticiones.push({
        metodo: req.method,
        url: req.url,
        headers: req.headers,
        cuerpo,
      });
      const respuesta =
        typeof estado.respuesta === 'function'
          ? estado.respuesta(req, cuerpo)
          : estado.respuesta;
      const { status = 201, body = {} } = respuesta ?? {};
      res.writeHead(status, { 'content-type': 'application/json' });
      res.end(JSON.stringify(body));
    });
  });
  await new Promise((resolver) => servidor.listen(puerto, '127.0.0.1', resolver));
  const direccion = servidor.address();
  return {
    url: `http://127.0.0.1:${direccion.port}`,
    puerto: direccion.port,
    peticiones: estado.peticiones,
    responder(valor) {
      estado.respuesta =
        typeof valor === 'function'
          ? valor
          : () => ({ status: valor.status, body: valor.body ?? {} });
    },
    cerrar: () => new Promise((resolver) => servidor.close(resolver)),
  };
}
