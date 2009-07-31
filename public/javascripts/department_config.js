jQuery(document).ready(function(){
    checkLastDay();
    $("#department_config_monthly").change(function(){
        checkLastDay();
    });
});

function checkLastDay(){
  if ($("#department_config_monthly option:selected").text() == "Weekly") {
            $("#month").hide();
            $("#month :option").attr("disabled", "disabled");
            $("#week :option").removeAttr("disabled");
            $("#week").show();
        } else {
            $("#week").hide();
            $("#week :option").attr("disabled", "disabled");
            $("#month :option").removeAttr("disabled");
            $("#month").show();
        }
}

