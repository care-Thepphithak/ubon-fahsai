import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["reportContainer"];
  static values = { reports: Array };

  selectedTag = null;
  selectedDateRange = null;

  filterByTag(event) {
    this.selectedTag = event.target.value;
    this.filter();
  }

  filterByDateRange(event) {
    this.selectedDateRange = event.target.value;
    this.filter();
  }

  filter() {
    if (!this.hasReportsValue) {
      return;
    }

    let filteredReports = this.reportsValue;

    // Filter by selectedTag
    if (this.selectedTag) {
      filteredReports = filteredReports.filter((report) => {
        let tags = [];

        if (typeof report.tags === "string") {
          try {
            tags = JSON.parse(report.tags);
          } catch (error) {
            tags = [];
          }
        } else if (Array.isArray(report.tags)) {
          tags = report.tags;
        }

        return tags.includes(this.selectedTag);
      });
    }

    // Sort by selectedDateRange (latest or oldest)
    if (this.selectedDateRange) {
      filteredReports = filteredReports.sort((a, b) => {
        const dateA = new Date(a.created_at);
        const dateB = new Date(b.created_at);

        if (this.selectedDateRange === "latest") {
          return dateB - dateA; // Sort descending (latest first)
        } else if (this.selectedDateRange === "oldest") {
          return dateA - dateB; // Sort ascending (oldest first)
        }
        return 0;
      });
    }

    this.updateReportList(filteredReports);
  }

  timeAgo(dateString) {
    const now = new Date();
    const date = new Date(dateString);
    const diffInSeconds = Math.floor((now - date) / 1000);

    const minutes = Math.floor(diffInSeconds / 60);
    const hours = Math.floor(diffInSeconds / 3600);
    const days = Math.floor(diffInSeconds / 86400);
    const months = Math.floor(diffInSeconds / 2592000);
    const years = Math.floor(diffInSeconds / 31536000);

    if (years > 0) {
      return years === 1 ? "1 ปี ที่แล้ว" : `${years} ปี ที่แล้ว`;
    }
    if (months > 0) {
      return months === 1 ? "1 เดือน ที่แล้ว" : `${months} เดือน ที่แล้ว`;
    }
    if (days > 0) {
      return days === 1 ? "1 วัน ที่แล้ว" : `${days} วัน ที่แล้ว`;
    }
    if (hours > 0) {
      return hours === 1 ? "1 ชั่วโมง ที่แล้ว" : `${hours} ชั่วโมง ที่แล้ว`;
    }
    if (minutes > 0) {
      return minutes === 1 ? "1 นาที ที่แล้ว" : `${minutes} นาที ที่แล้ว`;
    }
    if (diffInSeconds < 60) {
      return "น้อยกว่า 1 นาที";
    }
    return "เมื่อสักครู่";
  }

  updateReportList(reports) {
    this.reportContainerTarget.innerHTML = reports
      .map((report, index) => {
        let tags = [];

        if (typeof report.tags === "string") {
          try {
            tags = JSON.parse(report.tags);
          } catch (error) {
            tags = [];
          }
        } else if (Array.isArray(report.tags)) {
          tags = report.tags;
        }

        let tagsHtml = tags
          .map((tag) => `<p class="px-2 py-1 text-gray-500 bg-gray-100 rounded-md font-normal">${tag || "ไม่มีข้อมูล"}</p>`)
          .join("");

        return `
          <div class="flex bg-white py-3 pr-[16px] ${index === 0 ? 'mt-4' : ''} rounded-lg hover:scale-[.98] cursor-pointer transition-all" data-action="click->admin-map#setViewByList" data-lat="${report.lat}" data-long="${report.long}" >
            <div class="flex flex-col gap-1 min-w-14 mx-4 items-center justify-center text-nowrap">
              <svg width="40" height="46" viewBox="0 0 30 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M8.27344 35.0512C1.092 31.0038 -0.798717 27.1728 0.282262 21.9405C1.08029 18.077 3.69339 14.9336 3.94394 11.0775C5.06018 13.1088 5.52659 14.5736 5.65132 16.6963C9.20151 12.3466 11.5475 6.32517 11.6865 0C11.6865 0 20.9334 5.43323 21.5402 13.6402C22.3362 11.9486 22.7369 9.26193 21.9409 7.5207C24.329 9.26202 38.3067 24.7203 20.0476 35.0512C23.4805 28.367 20.9332 19.3479 14.9728 15.1825C15.3709 16.9736 14.673 23.6538 12.036 26.5892C12.7667 21.6845 11.3409 19.6105 11.3409 19.6105C11.3409 19.6105 10.8515 22.3578 8.95276 25.133C7.2189 27.6673 6.01752 30.357 8.27344 35.0512Z" fill="${report.severity_color}"/>
              </svg>
              <p class="text-gray-500 text-sm">${report.severity_level}</p>
            </div>
            <div class="flex flex-col">
              <h2 class="font-normal text-black text-base line-clamp-2">${report.location_name}</h2>
              <p class="text-gray-500 text-[14px]">${report.time_ago_message}</p>
              <div class="flex gap-2 mt-3 flex-wrap">
                ${(tagsHtml)}
              </div>
            </div>
          </div>
         `;
      })
      .join("");
  }
}