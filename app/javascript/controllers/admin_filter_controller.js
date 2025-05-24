import { Controller } from "@hotwired/stimulus";
import createConsumer from "channels/consumer";

export default class extends Controller {
  static targets = ["reportContainer"];
  static values = { reports: Array };

  selectedTag = null;
  selectedDateRange = null;

  connect() {
    this.channel = createConsumer.subscriptions.create("ReportChannel", {
      received: (data) => {
        this.reportsValue = [data.message, ...this.reportsValue];
        this.filter();
      },
    });
  }

  filterByTag(event) {
    this.selectedTag = event.target.value;
    this.filter();
  }

  filterByDateRange(event) {
    this.selectedDateRange = event.target.value;
    this.filter();
  }

  parseTags(tags) {
    if (typeof tags === "string") {
      try {
        return JSON.parse(tags);
      } catch (error) {
        return [];
      }
    } else if (Array.isArray(tags)) {
      return tags;
    }
    return [];
  }

  filter() {
    if (!this.hasReportsValue) {
      return;
    }

    let filteredReports = this.reportsValue;

    if (this.selectedTag) {
      filteredReports = this.filterBySelectedTag(filteredReports);
    }

    if (this.selectedDateRange) {
      filteredReports = this.sortByDateRange(filteredReports);
    }

    this.updateReportList(filteredReports);
  }

  filterBySelectedTag(reports) {
    return reports.filter((report) => {
      const tags = this.parseTags(report.tags);
      return tags.includes(this.selectedTag);
    });
  }

  sortByDateRange(reports) {
    return reports.sort((a, b) => {
      const dateA = new Date(a.created_at);
      const dateB = new Date(b.created_at);

      if (this.selectedDateRange === "latest") {
        return dateB - dateA;
      } else if (this.selectedDateRange === "oldest") {
        return dateA - dateB;
      }
      return 0;
    });
  }

  updateReportList(reports) {
    this.reportContainerTarget.scrollTop = 0;

    this.reportContainerTarget.innerHTML = reports
      .map((report, index) => {
        const tags = this.parseTags(report.tags);

        let tagsHtml = tags
          .map((tag) => `<p class="px-2 py-1 text-gray-500 bg-gray-100 rounded-md font-normal" data-testid="tags">${tag || "ไม่มีข้อมูล"}</p>`)
          .join("");

        return `
          <div class="flex bg-white py-3 pr-[16px] ${index === 0 ? 'mt-4' : ''} rounded-lg hover:scale-[.98] cursor-pointer transition-all" data-action="click->admin-map#setViewByList" data-lat="${report.lat}" data-long="${report.long}" >
            <div class="flex flex-col gap-1 min-w-14 mx-4 items-center justify-center text-nowrap">
              <svg width="40" height="46" viewBox="0 0 30 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M8.27344 35.0512C1.092 31.0038 -0.798717 27.1728 0.282262 21.9405C1.08029 18.077 3.69339 14.9336 3.94394 11.0775C5.06018 13.1088 5.52659 14.5736 5.65132 16.6963C9.20151 12.3466 11.5475 6.32517 11.6865 0C11.6865 0 20.9334 5.43323 21.5402 13.6402C22.3362 11.9486 22.7369 9.26193 21.9409 7.5207C24.329 9.26202 38.3067 24.7203 20.0476 35.0512C23.4805 28.367 20.9332 19.3479 14.9728 15.1825C15.3709 16.9736 14.673 23.6538 12.036 26.5892C12.7667 21.6845 11.3409 19.6105 11.3409 19.6105C11.3409 19.6105 10.8515 22.3578 8.95276 25.133C7.2189 27.6673 6.01752 30.357 8.27344 35.0512Z" fill="${report.severity_color}"/>
              </svg>
              <p class="text-gray-500 text-sm" data-testid="severity-level">${report.severity_level}</p>
            </div>
            <div class="flex flex-col">
              <h2 class="font-normal text-black text-base line-clamp-2" data-testid="location-name">${report.location_name}</h2>
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