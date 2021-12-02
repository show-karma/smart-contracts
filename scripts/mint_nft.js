address='0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6'
factory = await ethers.getContractAt('NFTMinterFactory', address)
await factory.deployMinter("Zastrin", "http://www.zastrin.com", '0x537f62D5f099EDd9F0FE78501D8C9D096082B573', 'Zastrin', 'ZST')

val = await factory.nftContractInfo('ZST')
minter = await ethers.getContractAt('NFTMinter', val.contractAddress)
res = await minter.mintToken('0xf768f5F340e89698465Fc7C12F31cB485fFf98D2', 'QmRpJtE9MLfxgRh58eSifNCsyMJVLFMsSADPFKnQaXHFzF')
