<html>
    <head>
        <title>Azure Virtual Maschine Information</title>
    </head>
    <body>

    <?php

    $options = array(
        'http'=>array(
            'method'=>"GET",
            'header'=>"Metadata:true"
        )
    );

    $json=file_get_contents("http://169.254.169.254/metadata/instance?api-version=2017-08-01",false, stream_context_create($options));
    $data =  json_decode($json);

    echo("Computer Name: " . $data->compute->name);

    ?>
    </body>
</html>