$aq = [ '192.168.1.2', '192.168.1.1' ]
if bind_grammar("allow-query", $aq) == "allow-query { 192.168.1.2; 192.168.1.1; };" {
  notice("allow-query okay")
} else {
  fail("allow-query fail")
}

if bind_grammar("update-policy", 'local') == "update-policy local;" {
  notice("update-policy okay")
} else {
  fail("update-policy fail")
}

$f = [ { '1.1.1.1' => { 'port' => 53 } } ]
$fr = bind_grammar("forwarders", $f)
if $fr == "forwarders { 1.1.1.1 port 53; };" {
  notice("forwarders okay")
} else {
  fail("forwarders fail: ${fr}")
}

$ns = { '1.1.1.1' => { 'port' => 53 } }
$nsr = bind_grammar("notify-source", $ns)
if $nsr == "notify-source 1.1.1.1 port 53;" {
  notice("notify-source okay")
} else {
  fail("notify-source fail: ${nsr}")
}

$m = [ { '1.1.1.1' => { 'port' => 53, 'key' => 'foo' } } ]
$mr = bind_grammar("masters", $m)
if $mr == "masters { 1.1.1.1 port 53 key foo; };" {
  notice("masters okay")
} else {
  fail("masters fail: ${mr}")
}
