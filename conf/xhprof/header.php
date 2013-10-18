<?php

function is_ajax()
{
    return (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest');
}

if (extension_loaded('xhprof') && !is_ajax())
{
    include_once '/var/xhprof/xhprof_lib/utils/xhprof_lib.php';
    include_once '/var/xhprof/xhprof_lib/utils/xhprof_runs.php';
    xhprof_enable(XHPROF_FLAGS_CPU + XHPROF_FLAGS_MEMORY);
}
?>