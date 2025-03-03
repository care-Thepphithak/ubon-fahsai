import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
    static targets = ["map"]
    polygonArea = []

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
        // start draw new polygon
        map.editTools.startPolygon();
        
        // update polygon area
        map.editTools.on('editable:drawing:end', (e) => {
            this.polygonArea = e.layer.getLatLngs();
            console.log(this.polygonArea);
        });
    }

    addStartEditPolygonButton(map, loadingControl) {
        const locationButton = L.control({ position: 'topright' });

        locationButton.onAdd = () => {
            const div = L.DomUtil.create('div', 'leaflet-bar leaflet-control');
            const button = L.DomUtil.create('button', 'bg-white cursor-pointer w-[30px] h-[30px] text-lg ', div);
            button.innerHTML = '<i class="fa-solid fa-draw-polygon "></i>';
           
            L.DomEvent.on(button, 'click', (e) => {
                this.startEditPolygon(map);
                button.classList.add('text-[#FF6159]');
               
            });

            return div;
        };

        locationButton.addTo(map);
    }
}