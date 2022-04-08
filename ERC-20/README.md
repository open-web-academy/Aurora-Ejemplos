---
título: "Aurora: Introducción a Hardhat"
---

## Introducción

El objetivo principal de este tutorial es mostrar cómo implementar e interactuar con
los contratos inteligentes de Solidity en Aurora utilizando HardHat. Este tutorial asume que
está familiarizado con `HardHat` y los tokens ERC-20. Para más detalles sobre
el estándar de token fungible, consulte
la [Especificación estándar ERC-20] (https://eips.ethereum.org/EIPS/eip-20).

## Instalación

Este tutorial asume que tiene Node.js 12+ y Yarn. Por favor vaya a [Cómo instalar Yarn](https://classic.yarnpkg.com/en/docs/install#mac-stable)
si aún no tiene el comando yarn instalado localmente.

- Para instalar los paquetes de requisitos previos, clone el repositorio de ejemplos:

```bash
clon de git https://github.com/open-web-academy/Aurora-Examples
cd Aurora-Examples/hardhat/erc20/
```

- Agregue su clave privada de Aurora (de MetaMask) al archivo __.env__ y
luego ejecute hilo: <br/>

```bash
echo "AURORA_CLAVE_PRIVADA=TU_AURORA_CLAVE_PRIVADA_AQUÍ" >> .env
instalación de hilo
```

## Implementar ERC-20

El ejemplo ERC-20 se trata de un token de sandía ingenuo 🍉. puedes intercambiar
en sandías reales 🍉🍉🍉. El suministro total es `1000000`, el
minter es la dirección del implementador del contrato y los decimales son `0`
(Una ficha --> Una sandía).

Para implementar el contrato de token 'ERC-20', use el siguiente comando:

```bash
$ hacer desplegar RED=testnet_aurora
hilo hardat ejecutar scripts/deploy.js --network testnet_aurora
correr hilo v1.22.10
Implementación de contratos con la cuenta: 0x6A33382de9f73B846878a57500d055B981229ac4
Saldo de la cuenta: 2210010200000000000
WatermelonToken implementado en: 0xD7f2A76F5DA173043E6c61a0A18D835809A07766
✨ Hecho en 14.96s.

# exportar la dirección del token
$ export TOKEN_ADDRESS='SU SALIDA DE IMPLEMENTACIÓN (por ejemplo, 0xD7f2A76F5DA173043E6c61a0A18D835809A07766)'
```

## Tareas de casco

Las tareas HardHat se encargan de analizar los valores proporcionados para cada parámetro.
Obtiene los valores, realiza la validación de tipo y los convierte en el tipo deseado.

En este ejemplo, revisaremos un conjunto de tareas HardHat predefinidas
que utiliza HardHat Runtime Environment ([HRE](https://hardhat.org/advanced/hardhat-runtime-environment.html)). Para completar el tutorial,
debes usarlos en el mismo orden:

### Saldo ETH

La siguiente tarea de HardHat utiliza el complemento `Web3` para obtener el saldo de la cuenta:

```javascript
task("saldo", "Imprime el saldo de una cuenta")
  .addParam("cuenta", "La dirección de la cuenta")
  .setAction(tareas asincrónicas => {
    const cuenta = web3.utils.toChecksumAddress(taskArgs.account);
    saldo const = esperar web3.eth.getBalance(cuenta);

    console.log(web3.utils.fromWei(balance, "ether"), "ETH");
  });
```

Para obtener el saldo `ETH`, utilice el siguiente comando:

```bash
Saldo de casco duro npx --network testnet_aurora --cuenta 0x6A33382de9f73B846878a57500d055B981229ac4
2.2100102 ETH
```

Debería notar que `--network` es una opción integrada global (parámetro)
en HardHat. También lo usaremos para los siguientes comandos.

### Suministro total

El siguiente script de tarea obtiene el suministro total del token Watermelon ERC-20.
Primero adjunta el
contrato de token, obtiene la dirección del remitente y finalmente recupera el suministro total
llamando al método `totalSupply()` en nuestro contrato ERC-20. El `--token`
dirección es la dirección del contrato ERC-20.

```javascript
task("totalSupply", "Suministro total del token ERC-20")
.addParam("token", "Dirección del token")
.setAction(async function ({ token }, { ethers: { getSigners } }, runSuper) {
  const sandíaToken = esperar ethers.getContractFactory("WatermelonToken")
  const sandía = sandíaToken.attach(token)
  const [minter] = esperar ethers.getSigners();
  const totalSupply = (esperar (esperar sandía.conectar(minter)).totalSupply()).toNumber()
  console.log(`El suministro total es ${suministrototal}`);
});
```

Para obtener `totalSupply`, use el siguiente comando:

```bash
$ npx hardhat totalSupply --token $TOKEN_ADDRESS --network testnet_aurora
El suministro total es 1000000
```

### Transferir ERC-20

La opción de "transferencia" permite que cualquier persona que tenga tokens ERC-20 pueda transferir
a cualquier dirección de Ethereum. En el siguiente script, la dirección minter
acuñará (implícitamente) y transferirá tokens `10 WTM` a la dirección `spender`:

```javascript
tarea("transferencia", "transferencia ERC-20")
    .addParam("token", "Dirección del token")
    .addParam("gastador", "Dirección del gastador")
    .addParam("cantidad", "cantidad de token")
    .setAction(async function ({ token, gastador, cantidad }, { ethers: { getSigners } }, runSuper) {
        const sandíaToken = esperar ethers.getContractFactory("WatermelonToken")
        const sandía = sandíaToken.attach(token)
        const [minter] = esperar ethers.getFirmantes();
        esperar (esperar sandía.conectar(minter).transferir(gastador, monto)).esperar()
        console.log(`${minter.address} ha transferido ${cantidad} a ${gastador}`);
    });
```

Para llamar a `transfer`, usa el siguiente comando:

```bash
$ npx transferencia de casco --token $TOKEN_ADDRESS --amount 10 --spender 0x2531a4D108619a20ACeE88C4354a50e9aC48ecfe --network testnet_aurora
0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 ha transferido 10 tokens a 0x2531a4D108619a20ACeE88C4354a50e9aC48ecfe
```

### Saldo de ERC-20

Podemos probar que el "gastador" ha recibido la cantidad exacta de fichas
llamando a `balanceOf` como se muestra a continuación:

```javascript
task("balanceOf", "Suministro total de token ERC-20")
.addParam("token", "Dirección del token")
.addParam("cuenta", "Dirección de cuenta")
.setAction(async function ({ token, cuenta }, { ethers: { getSigners } }, runSuper) {
  const sandíaToken = esperar ethers.getContractFactory("WatermelonToken")
  const sandía = sandíaToken.attach(token)
  const [minter] = esperar ethers.getSigners();
  const saldo = (esperar (esperar sandía.conectar(minter)).saldoDe(cuenta)).toNumber()
  console.log(`La cuenta ${cuenta} tiene un saldo total de fichas: ${saldo} WTM`);
});
```

Para obtener el `saldo`, utilice el siguiente comando:

```bash
$ npx hardhat balanceOf --token $TOKEN_ADDRESS --cuenta 0x6A33382de9f73B846878a57500d055B981229ac4 --red testnet_aurora
La cuenta 0x6A33382de9f73B846878a57500d055B981229ac4 tiene un saldo total de tokens: 999970 WTM
```

### Aprobar ERC-20

En algunos casos, en lugar de llamar a la `transferencia` directamente, el remitente
puede aprobar una cantidad específica de tokens para ser retirados de su cuenta
a la dirección específica del destinatario más tarde. Esto se puede hacer llamando a `aprobar`
luego llamar a `transferFrom`.

```javascript
tarea("aprobar", "ERC-20 aprobar")
    .addParam("token", "Dirección del token")
    .addParam("gastador", "Dirección del gastador")
    .addParam("cantidad", "cantidad de token")
    .setAction(async function ({ token, gastador, cantidad }, { ethers: { getSigners } }, runSuper) {
        const sandíaToken = esperar ethers.getContractFactory("WatermelonToken")
        const sandía = sandíaToken.attach(token)
        const [remitente] = espera ethers.getSigners();
        esperar (esperar sandía.conectar(remitente).aprobar(gastador, cantidad)).esperar()
        console.log(`${sender.address} ha aprobado ${cantidad} tokens para ${gastador}`);
    });

módulo.exportaciones = {};
```

Para llamar a `aprobar`, use el siguiente comando:

```bash
npx casco aprobar --token $TOKEN_ADDRESS --gastador 0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771 --cantidad 10 --network testnet_aurora
0x6A33382de9f73B846878a57500d055B981229ac4 ha aprobado 10 tokens para 0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771
```

### Transferir desde ERC-20

Después de aprobar los tokens, un destinatario puede llamar a `transferFrom` para mover
la "asignación" a su cuenta.

```javascript
tarea("transferirDesde", "ERC-20 transferirDesde")
    .addParam("token", "Dirección del token")
    .addParam("remitente", "Dirección del remitente")
    .addParam("cantidad", "cantidad de token")
    .setAction(async function ({ token, remitente, cantidad }, { ethers: { getSigners } }, runSuper) {
        const sandíaToken = esperar ethers.getContractFactory("WatermelonToken")
        const sandía = sandíaToken.attach(token)
        const [destinatario] = espera ethers.getSigners()
        consola.log(destinatario.dirección);
        esperar (esperar sandía.conectar(destinatario).transferirDe(remitente, destinatario.dirección, cantidad)).esperar()
        console.log(`${recipient.address} ha recibido ${amount} tokens de ${sender}`)
    });
```

Para llamar a `transferFrom`, usa el siguiente comando:

```bash
# exportar la clave privada del destinatario
AURORA_PRIVATE_KEY="LA CLAVE PRIVADA DEL RECEPTOR" npx hardhat transferFrom --token $TOKEN_ADDRESS --sender 0x6A33382de9f73B846878a57500d055B981229ac4 --amount 10 --network testnet_aurora
0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771 ha recibido 10 tokens de 0x6A33382de9f73B846878a57500d055B981229ac4
```

Comprobando el saldo de `0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771`:

```bash
npx hardhat balanceOf --token $TOKEN_ADDRESS --cuenta 0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771 --network testnet_aurora
La cuenta 0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771 tiene un saldo total de tokens: 10 WTM
```

## Conclusión

En este tutorial, implementamos un token ERC-20 usando HardHat en Aurora
TestNet, tokens ERC-20 transferidos y aprobados. Además, añadimos otros
tareas de servicios públicos, como obtener el suministro total y el saldo de la cuenta.
La única diferencia es que cambiamos Ethereum MainNet a Aurora
Punto final de RPC.