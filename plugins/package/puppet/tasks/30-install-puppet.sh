run_in_target apt-get update

run_in_target apt-get install -y puppet

run_in_target update-rc.d puppet disable

cat <<EOF >"${TARGET}"/etc/puppet/puppet.conf
[main]
        confdir = /etc/puppet
        vardir = /var/lib/puppet
        ssldir = $vardir/ssl
        logdir = /var/log/puppet
        rundir = /var/run/puppet

        factpath = $vardir/lib/facter

        pluginsync = true

[agent]
        server = PUPPETSERVER
        configtimeout = 900

        report = true

        usecacheonfailure = false
EOF
