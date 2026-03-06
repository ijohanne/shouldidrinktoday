    $(document).ready(function () {
        var number = 1 + Math.floor(Math.random() * 100);
        if(number > 50) {
            $("#showanswer").text("Yes");
        } else {
            $("#showanswer").text("No - Unless you want to");
        }
    });
