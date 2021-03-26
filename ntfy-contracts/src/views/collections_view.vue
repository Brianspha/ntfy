<template>
  <v-container fluid>
    <v-row>
      <v-col v-for="(collection, i) in collections" :key="i" cols="12" md="4">
        <v-card class="mx-auto" max-width="344">
          <expandable-image
            :src="collection.signature_url"
            height="200px"
            class="image"
          />
          <v-card-title>
            NFT Name
          </v-card-title>
          <v-card-subtitle>
            {{ collection.nft_name }}
          </v-card-subtitle>
          <v-card-subtitle>
            <div>Description</div>
            {{ collection.description }}
          </v-card-subtitle>
          <v-card-subtitle>
            <div>Time Stamp</div>
            {{ new Date(collection.time_stamp).toLocaleString() }}
          </v-card-subtitle>
          <v-card-actions v-if="collection.owned">
            <v-spacer />
            <v-btn @click="burnNFT(collection)" text>
              Burn
            </v-btn>
            <v-btn
              @click="
                $store.state.selectedTransferNFT = i + 1;
                $store.state.transferDialog = true;
              "
              :color="$store.state.primaryTextColor"
              text
            >
              Transfer
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
    <Transfer_dialog_view />
  </v-container>
</template>

<script>
import Transfer_dialog_view from "./transfer_dialog_view.vue";
var axios = require("axios");

export default {
  components: {
    Transfer_dialog_view,
  },
  data() {
    return {
      collections: [],
    };
  },
  mounted() {
    this.init();
  },
  methods: {
    burnNFT(token) {
      console.log("burning token: ", token);
      this.$store.state.deployedNFT.methods
        .burnToken(token.index - 1)
        .send({ gas: 6000000, from: this.$store.state.userAddress })
        .then((receipt, error) => {
          this.$store.state.isLoading = false;
          this.collections.splice(token.index - 1, 1);
          this.$store.dispatch("success", "Successfully burnt NFT");
        })
        .catch((error) => {
          this.$store.state.isLoading = false;
          this.$store.dispatch(
            "error",
            "Something went wrong whilst burning NFT"
          );
          console.log("error: ", error);
        });
    },
    init() {
      this.collections = [];
      this.$store.state.isLoading = true;
      let _this = this;
      this.$store.state.deployedNFT.methods
        .totalSupply()
        .call({ from: this.$store.state.userAddress })
        .then(async (total, error) => {
          console.log("totalSupply: ", total);
          for (var i = 0; i < total; i++) {
            var exists = await _this.$store.state.deployedNFT.methods
              .tokenExists(i + 1)
              .call({ gas: 6000000, from: _this.$store.state.userAddress });
            if (exists) {
              var ownedByUser = await _this.$store.state.deployedNFT.methods
                .ownerOf(i + 1)
                .call({ gas: 6000000, from: _this.$store.state.userAddress });
              console.log("ownedByUser: ", ownedByUser);
              var uri = await _this.$store.state.deployedNFT.methods
                .tokenURI(i + 1)
                .call({ from: _this.$store.state.userAddress });
              if (
                ownedByUser.toUpperCase() ===
                _this.$store.state.userAddress.toUpperCase()
              ) {
                console.log("uri: ", uri);
                axios.get(uri).then(function(response) {
                  console.log(response.data);

                  response.data.owned = true;
                  response.data.index = i + 1;
                  console.log("owned: ", response.data);
                  _this.collections.push(response.data);
                });
              } else {
                axios.get(uri).then(function(response) {
                  console.log(response.data);

                  response.data.owned = false;
                  response.data.index = i + 1;
                  console.log("not owned: ", response.data);
                  _this.collections.push(response.data);
                });
              }
            }
          }

          _this.$store.state.isLoading = false;
        })
        .catch((error) => {
          _this.$store.state.isLoading = false;
          console.log("error getting total supply: ", error);
        });
    },
  },
};
</script>

<style></style>
