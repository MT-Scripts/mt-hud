$(document).ready(function () {
    function updatePlayerHUD(data) {
        if (data.health <= 100) {
            $("#health-container").fadeIn("slow");
            $("#health").css("width", data.health + "%");
        } // else { $('#health-container').fadeOut('slow') }

        if (data.armor > 0) {
            $("#armor-container").fadeIn("slow");
            $("#armor").css("width", data.armor + "%");
        } else {
            $("#armor-container").fadeOut("slow");
        }

        if (data.thirst < 100) {
            $("#thirst-container").fadeIn("slow");
            $("#thirst").css("width", data.thirst + "%");
        } else {
            $("#thirst-container").fadeOut("slow");
        }

        if (data.hunger < 100) {
            $("#hunger-container").fadeIn("slow");
            $("#hunger").css("width", data.hunger + "%");
        } else {
            $("#hunger-container").fadeOut("slow");
        }

        if (data.stamina < 100) {
            $("#stamina-container").fadeIn("slow");
            $("#stamina").css("width", data.stamina + "%");
        } else {
            $("#stamina-container").fadeOut("slow");
        }

        if (data.voice <= 1.5) {
            $("#voice").css("width", "40px");
        } else if (data.voice <= 3.0) {
            $("#voice").css("width", "60px");
        } else {
            $("#voice").css("width", "75px");
        }

        if (data.radio) {
            $("#voice").css("background", "rgba(214, 71, 99, 0.8)");
        } else if (data.talking) {
            $("#voice").css("background", "rgba(240, 252, 25, 0.8)");
        } else {
            $("#voice").css("background", "rgba(212, 212, 212, 0.8)");
        }
    }

    function setSeatbelt(seatbeltOn) {
        if (seatbeltOn) {
            $('#seatbelt').css('display', 'none');
        } else {
            $('#seatbelt').css('display', '');
        }
    }

    function updateVehicleHUD(data) {
        $("#speed").text(data.speed);
        $('#altitude').text(data.altitude)
        $('#alt-txt').text(data.altitudetexto)
        $("#fuel").text(data.fuel);
        $("#gear").text(data.gear);
        $("#street1").text(data.street1);
        $("#street2").text(data.street2);
        $("#direction").text(data.direction);
        setSeatbelt(data.seatbelt)
    }

    window.addEventListener("message", function(event) {
        const data = event.data;
        if (data.action == "showPlayerHUD") {
            $("body").fadeIn("slow");
        } else if (data.action == "hidePlayerHUD") {
            $("body").fadeOut("slow");
        } else if (data.action == "updatePlayerHUD") {
            updatePlayerHUD(data);
        } else if (data.action == "showVehicleHUD") {
            $("#vehicle-hud-container").fadeIn("slow");
        } else if (data.action == "hideVehicleHUD") {
            $("#vehicle-hud-container").fadeOut("slow");
        } else if (data.action == "updateVehicleHUD") {
            updateVehicleHUD(data);
        } else if (data.action == 'setSeatbelt') {
            setSeatbelt(data.seatbelt)
        }
    });
});
