d3.csv("https://zhuyuhao.com/yuhao/star/chaifen/宇浩星陳全漢字拆分表.csv", function (data) {
    var dictionary = data;
    var button = d3.select("#button");
    var form = d3.select("#form");
    button.on("click", runEnter);
    form.on("keyup", runEnter);

    // Defining the function
    function runEnter() {
        d3.select("#tbody").html("")
        d3.event.preventDefault();
        var inputValue = d3.select("#user-input").property("value");
        var inputChars = [...inputValue];
        for (var n = 0; n < inputChars.length; n++) {
            var filteredDictionary =
                dictionary.filter(dictionary => dictionary.char.includes(inputChars[n]));
            var output = _.sortBy(filteredDictionary, 'code')
            for (var i = 0; i < filteredDictionary.length; i++) {
                d3.select("#tbody").insert("tr").html(
                    "<td><a href='https://zi.tools/zi/" + (output[i]['char']) + "'>" + (output[i]['char']) + "</a></td>" 
                    +
                    "<td>" + (output[i]['division']) + "</td>" 
                    +
                    "<td>" + (output[i]['code']) + "</td>" 
                    +
                    "<td>" + (output[i]['division_tw']) + "</td>" 
                    +
                    "<td>" + (output[i]['code_tw']) + "</td>" 
                    +
                    "<td>" + (output[i]['region']) + "</td>"
                    )
            }
        }

        // d3.select("#tbody2").html("")
        // d3.event.preventDefault();
        // var inputValue = d3.select("#user-input").property("value");
        // var inputChars = [...inputValue];
        // for (var n = 0; n < inputChars.length; n++) {
        //     var filteredDictionary =
        //         dictionary.filter(dictionary => dictionary.char.includes(inputChars[n]));
        //     var output = _.sortBy(filteredDictionary, 'code')
        //     for (var i = 0; i < filteredDictionary.length; i++) {
        //         d3.select("#tbody2").insert("tr").html(
        //             "<td><a href='https://zi.tools/zi/" + (output[i]['char']) + "'>" + (output[i]['char']) + "</a></td>" 
        //             +
        //             "<td>" + (output[i]['division']) + "</td>" 
        //             +
        //             "<td>" + (output[i]['code']) + "</td>" 
        //             +
        //             "<td>" + (output[i]['division_tw']) + "</td>" 
        //             +
        //             "<td>" + (output[i]['code_tw']) + "</td>" 
        //             +
        //             "<td>" + (output[i]['region']) + "</td>"
        //             )
        //     }
        // }
    };
});