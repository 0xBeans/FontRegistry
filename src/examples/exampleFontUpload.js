// Note: This is using Hardhat to upload the fonts

const fs = require("fs");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Initializing contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // todo: Update the addresses to attach to after deploy
  const ExampleFont = await ethers.getContractFactory("ExampleFont");
  const exampleFont = await ExampleFont.attach("<DEPLOYED_CONTRACT_ADDRESS>");

  // read base64 encoded font
  const file = await fs.readFileSync(
    __dirname + '/example-font.txt'
  );

  const content = file.toString();

  // file is 115kb so need to partition into 5
  const partition_size = content.length / 5
  const firstPart = content.substring(0, partition_size);
  const secondPart = content.substring(partition_size, partition_size*2)
  const thirdPart = content.substring(partition_size*2, partition_size*3)
  const fourthPart = content.substring(partition_size*3, partition_size*4);
  const fifthPart = content.substring(partition_size*4);

  // upload each partition
  let first = await exampleFont.saveFile(0, firstPart)
  let second = await exampleFont.saveFile(1, secondPart)
  let third = await exampleFont.saveFile(2, thirdPart)
  let fourth = await exampleFont.saveFile(3, fourthPart)
  let fifth = await exampleFont.saveFile(4, fifthPart)

  console.log('firstTxn', first);
  console.log('secondTxn', second);
  console.log('thirdTxn', third);
  console.log('fourthTxn', fourth);
  console.log('fifthTxn', fifth);

  // IMPORTANT: RENOUNCE OWNERSHIP ONCE FONT HAS BEEN TESTED AND READY TO BE SUBMITTED TO THE REGISTRY
  // FONTS MUST BE IMMUTABLE BEFORE GETTING ADDED TO THE REGISTRY
  await exampleFont.finalizeFont()

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });