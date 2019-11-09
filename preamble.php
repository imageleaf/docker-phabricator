<?php

if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $forwarded_for = $_SERVER['HTTP_X_FORWARDED_FOR'];
    if ($forwarded_for) {
        $origin_remote_addr = $_SERVER['REMOTE_ADDR'];
        $forwarded_for = explode(',', $forwarded_for);
        $possible_address = $origin_remote_addr;
        foreach ($forwarded_for as $address) {
            $address = trim($address);
            if (!$address) {
                continue;
            }
            if (!filter_var($address, FILTER_VALIDATE_IP,
                FILTER_FLAG_IPV4 | FILTER_FLAG_IPV6 | FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
                $possible_address = $address;
                break;
            }
        }

        $_SERVER['REMOTE_ADDR'] = $possible_address;
        $_SERVER['ORIGIN_REMOTE_ADDR'] = $origin_remote_addr;
    }
}

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
    $_SERVER['HTTPS'] = true;
}
