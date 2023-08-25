const Consul = require('consul');
const express = require('express');

// Obtiene el número de puerto de los argumentos de línea de comandos
//const portArg = process.argv[2] || 3000;
//const PORT = parseInt(portArg);

const SERVICE_NAME= process.env.SERVICE_NAME || 'microservicio';
const SERVICE_ID='m'+process.argv[2];
//const SERVICE_ID = `microservice-${PORT}-${Math.random().toString(36).substr(2, 9)}`;
const SCHEME='http';
const HOST='193.168.100.3';
const PORT=process.argv[2]*1;
//const HOST=process.env.HOST || 'private_ip';
const PID = process.pid;

/* Inicializacion del server */
const app = express();
const consul = new Consul();

app.get('/health', function (req, res) {
    console.log('Health check!');
    res.end( "Ok." );
    });

app.get('/', (req, res) => {
  console.log('GET /', Date.now());
  var s="<h1>Instancia '"+SERVICE_ID+"' del servicio '"+SERVICE_NAME+"'</h1>";
  s+="<h2>Listado de servicios</h2>";
  res.json({
    custom_html: s,
    data: Math.floor(Math.random() * 89999999 + 10000000),
    data_pid: PID,
    data_service: SERVICE_ID,
    data_host: HOST    
  });
});

app.listen(PORT, function () {
    console.log('Servicio iniciado en:'+SCHEME+'://'+HOST+':'+PORT+'!');
    });

/* Registro del servicio */
var check = {
  id: SERVICE_ID,
  name: SERVICE_NAME,
  address: HOST,
  port: PORT, 
  check: {
	   http: SCHEME+'://'+HOST+':'+PORT+'/health',
	   ttl: '5s',
	   interval: '5s',
     timeout: '5s',
     deregistercriticalserviceafter: '1m'
	   }
  };
 
consul.agent.service.register(check, function(err) {
  	if (err) throw err;
  	});
