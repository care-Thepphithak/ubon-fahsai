import consumer from "channels/consumer";

consumer.subscriptions.create("ReportChannel", {
  connected() {
    console.log("Connected to ReportChannel");
  },

  disconnected() {
    console.log("Disconnected from ReportChannel");
  },

  received(data) {

    const report_counter = document.getElementById("report_counter")
    report_counter.innerText = data.total_count;

    const report_harmful_counter = document.getElementById("report_harmful_counter")
    report_harmful_counter.innerText = data.harmful_count;
  },
});
