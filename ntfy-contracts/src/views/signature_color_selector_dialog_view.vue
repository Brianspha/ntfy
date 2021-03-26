<template>
  <v-dialog v-model="$store.state.colorDialog" height="100vh">
    <v-card>
      <v-card-title class="headline">
        Select Signiture Color
      </v-card-title>
      <v-card-text
        >This changes the color of the pen used to sign the NFT</v-card-text
      >
      <v-card-text style="text-align:center;">
        <v-col>
          <v-swatches
            v-model="$store.state.selectedSignatureColor"
            inline
          ></v-swatches>
        </v-col>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn text @click="$store.state.colorDialog = false">
          Cancel
        </v-btn>
        <v-btn
          :color="$store.state.primaryTextColor"
          text
          @click="$store.state.colorDialog = false"
        >
          Done
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script>
import VSwatches from "vue-swatches";

// Import the styles too, typically in App.vue or main.js
import "vue-swatches/dist/vue-swatches.css";
export default {
  components: { VSwatches },
};
</script>

<style></style>
