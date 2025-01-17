codes = true
read_globals = {
    -- Test.More
    'plan',
    'done_testing',
    'skip_all',
    'BAIL_OUT',
    'ok',
    'nok',
    'is',
    'isnt',
    'like',
    'unlike',
    'cmp_ok',
    'type_ok',
    'subtest',
    'pass',
    'fail',
    'require_ok',
    'eq_array',
    'is_deeply',
    'error_is',
    'error_like',
    'lives_ok',
    'diag',
    'note',
    'skip',
    'todo_skip',
    'skip_rest',
    'todo',
    -- Test.LongString
    'is_string',
    'is_string_nows',
    'like_string',
    'unlike_string',
    'contains_string',
    'lacks_string',
}
globals = {
    -- Spore
    'Spore',
}
ignore = { '212/req', '212/self' }
files['test/22-oauth.lua'].ignore = { '631' }
files['test/25-auth_digest.lua'].ignore = { '431', '631' }
files['test/33-format_xml.lua'].ignore = { '631' }
files['test/41-proxy_basic.lua'].ignore = { '122/os' }
