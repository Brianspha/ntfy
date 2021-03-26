import Vue from "vue";
import Vuex from "vuex";
import createPersistedState from "vuex-persistedstate";
import swal from "sweetalert2";
import bigNumber from "bignumber.js";

import WalletConnectProvider from "@walletconnect/web3-provider";
// @ts-ignore
import Fortmatic from "fortmatic";
import Torus from "@toruslabs/torus-embed";
import Authereum from "authereum";
import { Bitski } from "bitski";
import web3Modal from "web3modal";

require("dotenv").config();
console.log("process.env.VUE_APP_SECRET: ", process.env.VUE_APP_SECRET);
Vue.use(Vuex);
const { SkynetClient, genKeyPairFromSeed } = require("skynet-js");
const { privateKey, publicKey } = genKeyPairFromSeed(
  "this seed should be fairly long for security"
);
/* eslint-disable no-new */
const store = new Vuex.Store({
  plugins: [createPersistedState()],
  modules: {},
  state: {
    web3Modal: {},
    providers: {
      walletconnect: {
        package: WalletConnectProvider,
        options: {
          infuraId: process.env.VUE_APP_INFURA_ID,
        },
      },
      torus: {
        package: Torus,
      },
      fortmatic: {
        package: Fortmatic,
        options: {
          key: process.env.VUE_APP_FORTMATIC_KEY,
        },
      },
      authereum: {
        package: Authereum,
      },
    },
    transferDialog: false,
    selectedTransferNFT: -1,
    revision: 1,
    publicKey: publicKey,
    privateKey: privateKey,
    appSecret: process.env.VUE_APP_SECRET,
    nebulousClient: new SkynetClient("https://siasky.net/"),
    primaryTextColor: "#3b82f6",
    selectedSignatureColor: "#000000",
    colorDialog: false,
    nftDetailsDialog: false,
    signatureDetails: {},
    isLoading: false,
    erc721TokenInterface: require("../assets/contracts/erc721.json"),
    deployedNFT: require("../../embarkArtifacts/contracts/NFTY").default,
    userAddress: "",
  },
  actions: {
    success(context, message) {
      console.log("shwoing success message: ", message);
      swal.fire("Success", message, "success");
    },
    error(context, message) {
      console.log("shwoing error message: ", message);
      swal.fire("Error!", message, "error");
    },
    successWithFooter(context, message) {
      console.log("shwoing successWithFooter message: ", message);
      swal.fire({
        icon: "success",
        title: "Success",
        text: message.message,
        footer: `<a href= https://testnet.bscscan.com/tx/${message.txHash}> View on Binance Explorer</a>`,
      });
    },
  },
});

export default store;
