<template>
  <v-container flud>
    <v-row align="center" justify="center">
      <canvas ref="canvas" id="canvas" height="400px" width="400px" />
    </v-row>
    <v-spacer />
    <v-col align-self="start">
      <v-file-input
        label="Select Image"
        filled
        prepend-icon="mdi-camera"
        accept="image/*"
        v-model="image"
      ></v-file-input>
    </v-col>
    <v-row>
      <v-col align-self="center" style="text-align:center;"
        ><v-container>
          <v-row no-gutters>
            <v-col align-self="center">
              <v-btn
                v-if="signaturePad !== null"
                @click="clear"
                tile
                color="error"
              >
                <v-icon left>
                  mdi-cancel
                </v-icon>
                Clear
              </v-btn>
            </v-col>
            <v-col align-self="end">
              <v-btn
                v-if="signaturePad !== null"
                @click="$store.state.colorDialog = !$store.state.colorDialog"
                tile
                color="white"
              >
                <v-icon left>
                  mdi-select-color
                </v-icon>
                Select Color
              </v-btn>
            </v-col>
            <v-col align-self="end">
              <v-btn
                v-if="image !== null && signaturePad !== null"
                tile
                :color="$store.state.primaryTextColor"
                @click="mintNFT"
              >
                <v-icon left>
                  mdi-check
                </v-icon>
                Finish
              </v-btn>
            </v-col>
          </v-row>
        </v-container></v-col
      >
      <Signature_color_selector_dialog_view />
      <Mint_nft_dialog_view />
    </v-row>
  </v-container>
</template>
<script src="https://cdn.jsdelivr.net/npm/signature_pad@2.3.2/dist/signature_pad.min.js"></script>

<script>
import Mint_nft_dialog_view from "./mint_nft_dialog_view.vue";
import Signature_color_selector_dialog_view from "./signature_color_selector_dialog_view.vue";
export default {
  components: { Signature_color_selector_dialog_view, Mint_nft_dialog_view },

  data() {
    return {
      images: [],
      image: null,
      signaturePad: null,
      color: "#000000",
      dialog: false,
    };
  },

  mounted() {
    //  this.attachResize();
    // this.initPad();
    //window.onresize = this.attachResize();
  },
  methods: {
    mintNFT() {
      console.log(
        "this.signaturePad.toDataURL();: ",
        this.signaturePad.toDataURL()
      );
      this.$store.state.signatureDetails = this.signaturePad.toDataURL();
      this.$store.state.nftDetailsDialog = true;
    },
    initPad() {
      this.signaturePad = new SignaturePad(this.$refs.canvas);
    },
    attachResize() {
      // When zoomed out to less than 100%, for some very strange reason,
      // some browsers report devicePixelRatio as less than 1
      // and only part of the canvas is cleared then.
      var ratio = Math.max(window.devicePixelRatio || 1, 1);
      this.$refs.canvas.width = this.$refs.canvas.offsetWidth * ratio;
      this.$refs.canvas.height = this.$refs.canvas.offsetHeight * ratio;
      this.$refs.canvas.getContext("2d").scale(ratio, ratio);
      // resizeCanvas();
    },
    clear() {
      this.signaturePad.clear();
      this.image = null;
      this.signaturePad = null;
    },
    getImage() {
      //  this.$refs.fileUploader.click();
    },
  },
  watch: {
    "store.state.selectedSignatureColor": function(newVal, oldVal) {
      this.$store.state.colorDialog = !this.$store.state.colorDialog;
    },
    "$store.state.selectedSignatureColor": function(newVal, oldVal) {
      console.log("newVal color: ", newVal, " oldVal color: ", oldVal);
      this.signaturePad.penColor = newVal;
    },
    image: function(newVal, oldVal) {
      this.initPad();
      this.signaturePad.on();
      console.log("newVal: ", newVal, " oldVal: ", oldVal);
      var background = new Image();
      background.src = URL.createObjectURL(newVal);
      console.log("refs: ", this.$refs);
      var _this = this;

      background.addEventListener(
        "load",
        function() {
          var hRatio = _this.$refs.canvas.width / background.width;
          var vRatio = _this.$refs.canvas.height / background.height;
          var ratio = Math.min(hRatio, vRatio);
          var centerShift_x =
            (_this.$refs.canvas.width - background.width * ratio) / 2;
          var centerShift_y =
            (_this.$refs.canvas.height - background.height * ratio) / 2;
          _this.$refs.canvas
            .getContext("2d")
            .clearRect(
              0,
              0,
              _this.$refs.canvas.width,
              _this.$refs.canvas.height
            );
          console.log("background set");
          _this.$refs.canvas
            .getContext("2d")
            .drawImage(
              background,
              0,
              0,
              background.width,
              background.height,
              centerShift_x,
              centerShift_y,
              background.width * ratio,
              background.height * ratio
            );
        },
        false
      );
    },
  },
};
</script>

<style>
.sizing {
  width: 100%;
  height: 100%;
}
.primaryColorCustom {
  background: #3b82f6;
}
</style>
