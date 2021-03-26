<template>
  <v-row justify="center">
    <v-dialog v-model="$store.state.transferDialog" persistent max-width="290">
      <v-card>
        <v-card-title style="color:#3b82f6;">
          Transfer NFT
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-text-field
              label="NFT Index"
              v-model="$store.state.selectedTransferNFT"
              outlined
              readonly
            ></v-text-field>
          </v-row>
          <v-row>
            <v-text-field
              label="Receipient Address"
              v-model="receipientAddress"
              outlined
              :rules="addressRules"
            ></v-text-field>
          </v-row>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn text @click="$store.state.transferDialog = false">
            Cancel
          </v-btn>
          <v-btn v-if="valid" color="#3b82f6" text @click="transferNFT">
            Transfer
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-row>
</template>

<script>
import web3Utils from "web3-utils";
export default {
  data() {
    return {
      valid: false,
      receipientAddress: "",
      addressRules: [
        (v) => !!v || "NFT Name is required",
        (v) => (v && web3Utils.isAddress(v)) || "Invalid Address",
      ],
    };
  },
  watch: {
    receipientAddress: function(newVal, oldVal) {
      this.valid = web3Utils.isAddress(newVal);
    },
  },
  methods: {
    transferNFT() {
      this.$store.state.deployedNFT.methods
        .approve(this.receipientAddress, this.$store.state.selectedTransferNFT)
        .send({ gas: 6000000, from: this.$store.state.userAddress })
        .then((receipt, error) => {
          this.$store.state.deployedNFT.methods
            .safeTransferFrom(
              this.$store.state.userAddress,
              this.receipientAddress,
              this.$store.state.selectedTransferNFT
            )
            .send({ gas: 6000000, from: this.$store.state.userAddress })
            .then((receipt, error) => {
              console.log("receipt from transferring NFT: ", receipt);
              this.$store.state.isLoading = false;
              this.$store.dispatch("success", "Successfully transferred  NFT");
              this.$store.state.transferDialog = false;
            })
            .catch((error) => {
              this.$store.state.isLoading = false;
              this.$store.dispatch(
                "error",
                "Something went wrong whilst burning NFT"
              );
              console.log("error: ", error);
              this.$store.state.transferDialog = false;
            });
        })
        .catch((error) => {
          console.log("error transferring NFT: ", error);
          this.$store.state.isLoading = false;
          this.$store.dispatch(
            "error",
            "Something went wrong whilst transferring NFT"
          );
          this.$store.state.transferDialog = false;
        });
    },
  },
};
</script>

<style></style>
