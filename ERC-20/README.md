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
luego ejecute yarn: <br/>

```bash
echo "AURORA_CLAVE_PRIVADA=TU_AURORA_CLAVE_PRIVADA_AQUÍ" >> .env
instalación de yarn
```


## Implementar ERC-20

El ejemplo ERC-20 se trata de un token de sandía simple 🍉. Que luego podrías intercambiar
por sandías reales 🍉🍉🍉. El suministro total es `1000000`, el
minter es la dirección del implementador del contrato (quien hace el deploy) y los decimales son `0`

Para implementar el contrato de token 'ERC-20', use el siguiente comando:

```bash
$ make deploy NETWORK=testnet_aurora
yarn hardat run scripts/deploy.js --network testnet_aurora
yarn run v1.22.10
Deploying contracts with the account: 0x6A33382de9f73B846878a57500d055B981229ac4
Account balance: 2210010200000000000
WatermelonToken deployed to: 0xD7f2A76F5DA173043E6c61a0A18D835809A07766
✨  Done in 14.96s.

# exportar la dirección del token
$ export TOKEN_ADDRESS='YOUR OUTPUT FROM DEPLOY (e.g. 0xD7f2A76F5DA173043E6c61a0A18D835809A07766)'
```


## HardHat

Las tareas HardHat se encargan de analizar los valores proporcionados para cada parámetro.
Obtiene los valores, realiza la validación de tipo y los convierte en el tipo deseado.

En este ejemplo, revisaremos un conjunto de tareas HardHat predefinidas
que utiliza HardHat Runtime Environment ([HRE](https://hardhat.org/advanced/hardhat-runtime-environment.html)). Para completar el tutorial,
debes usarlos en el mismo orden:


### Saldo ETH

La siguiente tarea de HardHat utiliza el complemento `Web3` para obtener el saldo de la cuenta:

```javascript
task("balance", "Prints an account's balance")
  .addParam("account", "The account's address")
  .setAction(async taskArgs => {
    const account = web3.utils.toChecksumAddress(taskArgs.account);
    const balance = await web3.eth.getBalance(account);

    console.log(web3.utils.fromWei(balance, "ether"), "ETH");
  });
```

Para obtener el saldo `ETH`, utilice el siguiente comando:

```bash
npx hardhat balance --network testnet_aurora --account 0x6A33382de9f73B846878a57500d055B981229ac4
2.2100102 ETH
```

Debería notar que `--network` es una opción integrada global (parámetro)
en HardHat. También lo usaremos para los siguientes comandos.


### Suministro total

El siguiente script de tarea obtiene el suministro total del token Watermelon ERC-20.
Primero adjunta el contrato de token, obtiene la dirección del remitente y finalmente 
recupera el suministro total llamando al método `totalSupply()` en nuestro contrato 
ERC-20. El `--token` dirección es la dirección del contrato ERC-20.

```javascript
task("totalSupply", "Total supply of ERC-20 token")
.addParam("token", "Token address")
.setAction(async function ({ token }, { ethers: { getSigners } }, runSuper) {
  const watermelonToken = await ethers.getContractFactory("WatermelonToken")
  const watermelon = watermelonToken.attach(token)
  const [minter] = await ethers.getSigners();
  const totalSupply = (await (await watermelon.connect(minter)).totalSupply()).toNumber()
  console.log(`Total Supply is ${totalSupply}`);
});
```

Para obtener `totalSupply`, use el siguiente comando:

```bash
$ npx hardhat totalSupply --token $TOKEN_ADDRESS --network testnet_aurora
Total Supply is 1000000
```


### Transferir ERC-20

La opción de "transfer" permite que cualquier persona que tenga tokens ERC-20 pueda transferir
a cualquier dirección de Ethereum. En el siguiente script, la dirección minter
acuñará (implícitamente) y transferirá tokens `10 WTM` a la dirección `spender`:

```javascript
task("transfer", "ERC-20 transfer")
    .addParam("token", "Token address")
    .addParam("spender", "Spender address")
    .addParam("amount", "Token amount")
    .setAction(async function ({ token, spender, amount }, { ethers: { getSigners } }, runSuper) {
        const watermelonToken = await ethers.getContractFactory("WatermelonToken")
        const watermelon = watermelonToken.attach(token)
        const [minter] = await ethers.getSigners();
        await (await watermelon.connect(minter).transfer(spender, amount)).wait()
        console.log(`${minter.address} has transferred ${amount} to ${spender}`);
    });
```

Para llamar a `transfer`, usa el siguiente comando:

```bash
$ npx hardhat transfer --token $TOKEN_ADDRESS --amount 10 --spender 0x2531a4D108619a20ACeE88C4354a50e9aC48ecfe --network testnet_aurora
0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 has transferred 10 tokens to 0x2531a4D108619a20ACeE88C4354a50e9aC48ecfe
```


### Saldo de ERC-20

Podemos probar que el "gastador" o "spender" ha recibido la cantidad exacta de fichas
llamando a `balanceOf` como se muestra a continuación:

```javascript
task("balanceOf", "Total supply of ERC-20 token")
.addParam("token", "Token address")
.addParam("account", "Account address")
.setAction(async function ({ token, account }, { ethers: { getSigners } }, runSuper) {
  const watermelonToken = await ethers.getContractFactory("WatermelonToken")
  const watermelon = watermelonToken.attach(token)
  const [minter] = await ethers.getSigners();
  const balance = (await (await watermelon.connect(minter)).balanceOf(account)).toNumber()
  console.log(`Account ${account} has a total token balance:  ${balance} WTM`);
});
```

Para obtener el `saldo`, utilice el siguiente comando:

```bash
$ npx hardhat balanceOf --token $TOKEN_ADDRESS --account 0x6A33382de9f73B846878a57500d055B981229ac4 --network testnet_aurora
Account 0x6A33382de9f73B846878a57500d055B981229ac4 has a total token balance:  999970 WTM
```


### Aprobar ERC-20

En algunos casos, en lugar de llamar a `transfer` directamente, el remitente
puede approve una cantidad específica de tokens para ser retirados de su cuenta
a la dirección específica del destinatario más tarde. Esto se puede hacer llamando a `approve`
luego llamar a `transferFrom`.

```javascript
task("approve", "ERC-20 approve")
    .addParam("token", "Token address")
    .addParam("spender", "Spender address")
    .addParam("amount", "Token amount")
    .setAction(async function ({ token, spender, amount }, { ethers: { getSigners } }, runSuper) {
        const watermelonToken = await ethers.getContractFactory("WatermelonToken")
        const watermelon = watermelonToken.attach(token)
        const [sender] = await ethers.getSigners();
        await (await watermelon.connect(sender).approve(spender, amount)).wait()
        console.log(`${sender.address} has approved ${amount} tokens to ${spender}`);
    });

module.exports = {};
```

Para llamar a `approve`, use el siguiente comando:

```bash
npx hardhat approve --token $TOKEN_ADDRESS --spender 0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771 --amount 10 --network testnet_aurora
0x6A33382de9f73B846878a57500d055B981229ac4 has approved 10 tokens to 0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771
```


### TransferFrom de ERC-20

Después de aprobar los tokens, un destinatario puede llamar a `transferFrom` para mover
la "allowance" a su cuenta.

```javascript
task("transferFrom", "ERC-20 transferFrom")
    .addParam("token", "Token address")
    .addParam("sender", "Sender address")
    .addParam("amount", "Token amount")
    .setAction(async function ({ token, sender, amount }, { ethers: { getSigners } }, runSuper) {
        const watermelonToken = await ethers.getContractFactory("WatermelonToken")
        const watermelon = watermelonToken.attach(token)
        const [recipient] = await ethers.getSigners()
        console.log(recipient.address);
        await (await watermelon.connect(recipient).transferFrom(sender, recipient.address, amount)).wait()
        console.log(`${recipient.address} has received ${amount} tokens from ${sender}`)
    });
```

Para llamar a `transferFrom`, usa el siguiente comando:

```bash
# exportar la clave privada del destinatario
AURORA_PRIVATE_KEY="THE RECIPIENT PRIVATE KEY" npx hardhat transferFrom --token $TOKEN_ADDRESS --sender 0x6A33382de9f73B846878a57500d055B981229ac4  --amount 10 --network testnet_aurora
0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771 has received 10 tokens from 0x6A33382de9f73B846878a57500d055B981229ac4
```

Comprobando el saldo de `0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771`:

```bash
npx hardhat balanceOf --token $TOKEN_ADDRESS --account 0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771  --network testnet_aurora
Account 0x8722C88e82AbCC639148Ab6128Cd63333B2Ad771 has a total token balance:  10 WTM
```


## Conclusión

En este tutorial, implementamos un token ERC-20 usando HardHat en la testnet de Aurora.
Aprobamos u transferimos los tokens ERC-20.
Añadimos otras tareas como obtener el suministro total y el saldo de la cuenta.
Como se pudo observar la única diferencia a deployar en Ethereum MainNet es hacer el 
cambio al Aurora RPC endpoint en el archivo `hardhat.config.js`.