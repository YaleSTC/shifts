$(document).ready(function(){$("#advanced").hide();})
$(document).ready(function(){$("#advanced_link").show();})

var opts = {
                formElements:{"restriction_start_date_3i":"j",
                              "restriction_start_date_1i":"Y",
                              "restriction_start_date_2i":"n"
                },
                statusFormat:"l-cc-sp-d-sp-F-sp-Y",
                noFadeEffect:true,
                       };
datePickerController.createDatePicker(opts);

var opts = {
                formElements:{"restriction_end_date_3i":"j",
                              "restriction_end_date_1i":"Y",
                              "restriction_end_date_2i":"n"
                },
                statusFormat:"l-cc-sp-d-sp-F-sp-Y",
                noFadeEffect:true,
                       };
datePickerController.createDatePicker(opts);