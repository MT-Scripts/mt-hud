$(document).ready(function(){
    function updatePlayerHUD(data) {
        if (data.health < 100) {
            $('#health-container').fadeIn('slow')
            $('#health').css('width', data.health+"%")
        } else { $('#health-container').fadeOut('slow') }

        if (data.armor > 0) {
            $('#armor-container').fadeIn('slow')
            $('#armor').css('width', data.armor+"%")
        } else { $('#armor-container').fadeOut('slow') }

        if (data.thirst < 100) {
            $('#thirst-container').fadeIn('slow')
            $('#thirst').css('width', data.thirst+"%")
        } else { $('#thirst-container').fadeOut('slow') }

        if (data.hunger < 100) {
            $('#hunger-container').fadeIn('slow')
            $('#hunger').css('width', data.hunger+"%")
        } else { $('#hunger-container').fadeOut('slow') }

        if (data.stamina < 100) {
            $('#stamina-container').fadeIn('slow')
            $('#stamina').css('width', data.stamina+"%")
        } else { $('#stamina-container').fadeOut('slow') }

        if (data.voice <= 1.5) {
            $('#voice').css('width', "20px")
        } else if (data.voice <= 3.0) {
            $('#voice').css('width', "40px")
        } else {
            $('#voice').css('width', "60px")
        }

        if (data.talking) {
            $('#voice').css('background-color', "rgba(0, 97, 2, 0.641)")
        } else {
            $('#voice').css('background-color', "rgba(182, 182, 182, 0.641)")
        }
    }

    function updateVehicleHUD(data) {
        $('#speed').text(data.speed)

        $('#fuel').text(data.fuel)

        if (data.gear == 0) {
            $('#gear').text('R')
        } else {
            $('#gear').text(data.gear)
        }

        $('#street1').text(data.street1)

        $('#street2').text(data.street2)

        $('#direction').text(data.direction)
    }

    function showSettingsPanel(data) {
        $('body').css('display', "flex")
        $('body').css('justify-content', "center")
        $('body').css('align-items', "center")
        $('#settings-panel').fadeIn('slow')
        $.post('https://mt-hud/setUIFocus');
    }

    function hideSettingsPanel() {
        $('#settings-panel').css('display', "none")
        $('body').css('display', "block")
        $('body').css('justify-content', "")
        $('body').css('align-items', "")
        $.post('https://mt-hud/unsetUIFocus');
    }

    document.onkeyup = function (event) {
        const charCode = event.key;
        if (charCode == "Escape") {
            hideSettingsPanel();
        }
    };

    window.addEventListener('message', function(event) {
        const data = event.data;
        if (data.action == 'showPlayerHUD') {
            $('body').fadeIn('slow')
        } else if (data.action == 'hidePlayerHUD') {
            $('body').fadeOut('slow')
        } else if (data.action == 'updatePlayerHUD') {
            updatePlayerHUD(data)
        } else if (data.action == 'showVehicleHUD') {
            $('#vehicle-hud-container').fadeIn('slow')
        } else if(data.action == 'hideVehicleHUD') {
            $('#vehicle-hud-container').fadeOut('slow')
        } else if (data.action == 'updateVehicleHUD') {
            updateVehicleHUD(data)
        } else if (data.action == 'showSettingsPanel') {
            showSettingsPanel(data)
        }
    })
});