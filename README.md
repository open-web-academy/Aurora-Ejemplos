# Ejemplos desarrollados usando HardHat

En cada una de las carpetas se encuentran diferentes aplicaciones buscando servirle de ejemplos, cuyos contratos están desarrollados en Solidity y configurados para deployar en las redes de Aurora: 'testnet_aurora' o 'local_aurora'.

Para deployar los contratos deberá instalar las dependencias dentro de la carpeta de cada aplicación, con: 'npm install'
En algunos casos es necesario instalar también los contratos de OpenZeppelin con:  
```
npm install @openzeppelin/contracts
```
Para deployar un contrato, dentro de la carpeta correspondiente ejecutar:
```
npx hardhat run /script/deploy.js --network <nombre de la red>
```
Antes de hacer el deploy debe ir al archivo deploy.js y en el método deploy, dentro de los paréntesis, escribir los parámentros que recibirá el constructor, separados por comas y con conchetes en caso de tratarse de un string.

Para hacer algunas pruebas puede, ubicándose dentro de la carpeta ERC-20 y una vez deployado el contrato, ejecutar los siguientes comandos:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

En caso de querer hacer pruebas localmente instalar HardHat con 'npm install --save-dev hardhat' y luego ejecutar 'npx hardhat node'