const fs = require('fs');
const controller = JSON.parse(fs.readFileSync('build/contracts/Controller.json', 'utf8'));
fs.writeFileSync('abi/Controller.abi', JSON.stringify(controller.abi));
