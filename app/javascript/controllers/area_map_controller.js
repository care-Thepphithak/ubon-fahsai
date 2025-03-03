import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
    static targets = ["map"]

    connect() {
        const map = L.map(this.mapTarget, {
            center: [15.2313, 104.8567],
            zoom: 13,
            editable: true
        });
        const loadingControl = L.control({ position: 'topright' });
        this.map = map;

        L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution: '&copy; OpenStreetMap'
        }).addTo(map);

        this.addStartEditPolygonButton(map, loadingControl);
    }

    startEditPolygon(map) {
        console.log('startEditPolygon');
        var polyline = L.polyline([[15.2313, 104.8567], [15.2315, 104.8569]]).addTo(map);
        polyline.enableEdit();
    }

    addStartEditPolygonButton(map, loadingControl) {
        const locationButton = L.control({ position: 'topright' });

        locationButton.onAdd = () => {
            const div = L.DomUtil.create('div', 'leaflet-bar leaflet-control');
            const button = L.DomUtil.create('button', 'bg-white', div);
            button.innerHTML = '<i class="fa-solid fa-location-crosshairs"></i>';
            button.title = 'Show my location';
            button.style.width = '30px';
            button.style.height = '30px';
            button.style.fontSize = '20px';
            button.style.display = 'flex';
            button.style.alignItems = 'center';
            button.style.justifyContent = 'center';

            L.DomEvent.on(button, 'click', (e) => {
                this.startEditPolygon(map);
            });

            return div;
        };

        locationButton.addTo(map);
    }
}