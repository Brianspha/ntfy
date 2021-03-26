<template>
  <v-container fluid>
    <v-row justify="center">
      <v-dialog v-model="$store.state.nftDetailsDialog" persistent>
        <v-card>
          <v-card-title style="color:#3b82f6;">
            NFT Details
          </v-card-title>
          <v-card-text>
            <v-form ref="form" v-model="valid" lazy-validation>
              <v-row>
                <v-img :src="$store.state.signatureDetails" contain></v-img>
              </v-row>
              <v-row>
                <v-text-field
                  label="NFT Name"
                  placeholder="E.g. Pretty Plants"
                  v-model="nftName"
                  :rules="nftNameRules"
                  outlined
                ></v-text-field>
              </v-row>
              <v-row>
                <v-textarea
                  outlined
                  :rules="nftNameRules"
                  label="NFT Description"
                  v-model="nftDescription"
                ></v-textarea>
              </v-row>
            </v-form>
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn text @click="$store.state.nftDetailsDialog = false">
              Close
            </v-btn>
            <v-btn
              v-if="valid"
              :color="$store.state.primaryTextColor"
              text
              @click="mintNFT"
            >
              Mint
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-row>
  </v-container>
</template>

<script>
export default {
  data() {
    return {
      nftName: "",
      nftDescription: "",
      valid: true,
      nftNameRules: [(v) => !!v || "NFT Name is required"],
    };
  },
  methods: {
    mintNFT: async function() {
      let _this = this;
      if (this.$refs.form.validate()) {
        this.$store.state.isLoading = true;
        this.$store.state.nftDetailsDialog = false;
        const { skylink } = await this.$store.state.nebulousClient.uploadFile(
          this.dataURItoBlob(this.$store.state.signatureDetails)
        );
        console.log("SkyLink: ", skylink);
        var file = new File(
          [
            JSON.stringify({
              signature_url:
                "https://siasky.net/" + skylink.substring(4, skylink.length),
              description: _this.nftDescription,
              nft_name: _this.nftName,
              time_stamp: new Date().getTime(),
            }),
          ],
          "nft.json",
          { type: "text/plain" }
        );
        console.log("file: ", file);
        _this.$store.state.nebulousClient
          .uploadFile(file)
          .then((skylink1) => {
            console.log(`Upload successful, skylink1: `, skylink1.skylink);

            console.log(
              "this.$store.state.deployedNFT.methods: ",
              _this.$store.state.deployedNFT.methods
            );
            _this.$store.state.deployedNFT.methods
              .mintToken(
                _this.$store.state.userAddress,
                "https://siasky.net/" +
                  skylink1.skylink.substring(4, skylink1.skylink.length)
              )
              .send({
                gas: 6000000,
                from: _this.$store.state.userAddress,
              })
              .then((receipt, error) => {
                _this.$store.state.isLoading = false;
                console.log(
                  "receipt of sending transaction: ",
                  receipt,
                  " error: ",
                  error
                );

                _this.$store.dispatch(
                  "success",
                  "Successfully minted NFT token"
                );
                window.location.reload();
              })
              .catch((error) => {
                console.log("error uploading: ", error);
                _this.$store.state.isLoading = false;
                _this.$store.dispatch(
                  "error",
                  "Something went wrong whilst minting NFT"
                );
              });
          })
          .catch((error) => {
            console.log("error uploading: ", error);
            _this.$store.state.isLoading = false;
          });
      } else {
        _this.$store.dispatch("error", "Missing NFT details");
      }
    },
    dataURItoBlob(dataURI) {
      // convert base64 to raw binary data held in a string
      // doesn't handle URLEncoded DataURIs - see SO answer #6850276 for code that does this
      var byteString = atob(dataURI.split(",")[1]);

      // separate out the mime component
      var mimeString = dataURI
        .split(",")[0]
        .split(":")[1]
        .split(";")[0];

      // write the bytes of the string to an ArrayBuffer
      var ab = new ArrayBuffer(byteString.length);
      var ia = new Uint8Array(ab);
      for (var i = 0; i < byteString.length; i++) {
        ia[i] = byteString.charCodeAt(i);
      }

      //Old Code
      //write the ArrayBuffer to a blob, and you're done
      //var bb = new BlobBuilder();
      //bb.append(ab);
      //return bb.getBlob(mimeString);

      //New Code
      return new Blob([ab], { type: mimeString });
    },
    getSkyData: async function() {
      var test = await this.$store.state.nebulousClient.db.getJSON(
        this.$store.state.publicKey,
        this.$store.state.appSecret
      );
      return test;
    },
    saveData(data) {
      return new Promise((resolve) => {
        this.$store.state.nebulousClient.db
          .setJSON(
            this.$store.state.privateKey,
            this.$store.state.appSecret,
            data
            //(this.$store.state.revision)
          )
          .then((results) => {
            resolve(results);
            console.log("results of saving user data: ", results);
          });
      });
    },
  },
};
</script>

<style></style>
