import consumer from "channels/consumer";

consumer.subscriptions.create("ReportChannel", {
  connected() {
    console.log("Connected to ReportChannel");
  },

  disconnected() {
    console.log("Disconnected from ReportChannel");
  },

  received(data) {

    let tags = [];

    try {
      if (data.message.tags && data.message.tags.trim()) {
        tags = JSON.parse(data.message.tags);
      }
    } catch (error) {
      console.error("Error parsing tags:", error);
      tags = []; 
    }

    console.log(tags);

    const tagsHtml =
      tags
        .map((tag) => {
          return `<p class="px-2 py-0.5 bg-gray-300 rounded-md">${
            tag || "ไม่มีข้อมูล"
          }</p>`;
        })
        .join("") ?? "";

    function timeAgo(dateString) {
      const now = new Date();
      const date = new Date(dateString);
      const diffInSeconds = Math.floor((now - date) / 1000); 

      const minutes = Math.floor(diffInSeconds / 60);
      const hours = Math.floor(diffInSeconds / 3600);
      const days = Math.floor(diffInSeconds / 86400);
      const months = Math.floor(diffInSeconds / 2592000); 
      const years = Math.floor(diffInSeconds / 31536000); 

      if (years > 0) return `${years} ปี${years > 1 ? "s" : ""}`;
      if (months > 0) return `${months} เดือน${months > 1 ? "s" : ""}`;
      if (days > 0) return `${days} วัน${days > 1 ? "s" : ""}`;
      if (hours > 0) return `${hours} ชั่วโมง${hours > 1 ? "s" : ""}`;
      if (minutes > 0) return `${minutes} นาที${minutes > 1 ? "s" : ""}`;
      return `เมื่อสักครู่`;
    }

    const notificationContainer = document.getElementById("notifications");
    const report_counter = document.getElementById("report_counter")
    report_counter.innerText = data.total_count;

    const report_harmful_counter = document.getElementById("report_harmful_counter")
    report_harmful_counter.innerText = data.harmful_count;


    if (notificationContainer) {

      const notification = document.createElement("div");
      notification.classList.add("rounded");

      const reportContainer = document.getElementById("report-container");

      reportContainer.scrollTop = 0;



      notification.innerHTML = `
        <div class="flex bg-white py-3 pr-[16px] rounded-lg">
          <div class="flex flex-col mx-4 items-center justify-center w-fit min-w-18 text-nowrap">
            <svg width="40" height="46" viewBox="0 0 30 36" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M8.27344 35.0512C1.092 31.0038 -0.798717 27.1728 0.282262 21.9405C1.08029 18.077 3.69339 14.9336 3.94394 11.0775C5.06018 13.1088 5.52659 14.5736 5.65132 16.6963C9.20151 12.3466 11.5475 6.32517 11.6865 0C11.6865 0 20.9334 5.43323 21.5402 13.6402C22.3362 11.9486 22.7369 9.26193 21.9409 7.5207C24.329 9.26202 38.3067 24.7203 20.0476 35.0512C23.4805 28.367 20.9332 19.3479 14.9728 15.1825C15.3709 16.9736 14.673 23.6538 12.036 26.5892C12.7667 21.6845 11.3409 19.6105 11.3409 19.6105C11.3409 19.6105 10.8515 22.3578 8.95276 25.133C7.2189 27.6673 6.01752 30.357 8.27344 35.0512Z" fill="#FF392F"/>
            </svg>
            <p class="text-gray-500">${data.message.severity_level}</p>
          </div>
          <div class="flex flex-col">
            <h2 class="font-bold text-black text-base line-clamp-2">${
              data.message.location_name
            }</h2>
            <p class="text-gray-500 text-[14px]">${timeAgo(
              data.message.created_at
            )}</p>
            <div class="flex gap-1 mt-3 flex-wrap">
              ${tagsHtml ?? ""}
            </div>
          </div>
        </div>
      `;
      notificationContainer.prepend(notification);
    }
  },
});
