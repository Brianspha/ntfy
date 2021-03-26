<template>
  <!-- App.vue -->

  <v-app>
    <!-- Sizes your content based upon application components -->
    <v-main>
      <!-- Provides the application the proper gutter -->
      <v-container fluid>
        <v-card class="mx-auto">
          <v-app-bar class="primaryColorCustom">
            <v-toolbar-title>NFTY</v-toolbar-title>
            <v-spacer></v-spacer>
          </v-app-bar>
          <v-container fluid>
            <v-tabs class="primaryColorCustom" right>
              <v-tab>Mint</v-tab>
              <v-tab>Collection</v-tab>
              <v-tab-item>
                <v-container fluid>
                  <signiture_view />
                </v-container>
              </v-tab-item>
              <v-tab-item>
                <v-container fluid><collections_view /> </v-container>
              </v-tab-item>
            </v-tabs>
          </v-container>
        </v-card>
        <v-overlay :value="$store.state.isLoading">
          <v-progress-circular indeterminate size="64"></v-progress-circular>
        </v-overlay>
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
import signiture_view from "./views/signiture_view.vue";
import detectEthereumProvider from "@metamask/detect-provider";
import EmbarkJS from "../embarkArtifacts/embarkjs";
import collections_view from "./views/collections_view";
import Web3Modal from "web3modal";

export default {
  components: { signiture_view, collections_view },
  beforeMount() {
    const provider = detectEthereumProvider().then(async (provider) => {
      if (provider) {
        /*  this.$store.state.web3Modal = new Web3Modal({
          // network: "mainnet", // optional
          cacheProvider: true, // optional
          providerOptions: this.$store.state.providers,
        });
        // From now on, this should always be true:
        // provider === window.ethereum
        //EmbarkJS.enableEthereum();
        //var results = await this.$store.state.web3Modal.connect();
        console.log("connected to wallet: ", results);*/
        ethereum.request({ method: "eth_requestAccounts" });
        ethereum.on("accountsChanged", (accounts) => {
          this.$store.state.userAddress = accounts[0];
          window.location.reload();
        });
        ethereum.on("chainChanged", (_chainId) => window.location.reload());
        let _this = this;
        _this.$store.state.isLoading = true;
        ethereum.request({ method: "eth_accounts" }).then((accounts) => {
          console.log("accounts: ", accounts);
          _this.$store.state.userAddress = accounts[0];
          _this.$store.state.isLoading = false;
        });
      } else {
        this.$store.dispatch("error", "Metamask is not installed");
      }
    });
  },
  methods: {},
};
</script>

<style>
.primaryColorCustom {
  background: #3b82f6;
}
#primaryColor {
  background: #3b82f6;
  opacity: 0.5;
}
</style>
