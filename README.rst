===================================
Immunity Monitoring OpenWrt package
===================================

.. image:: https://github.com/edge-servers/openwrt-immunity-monitoring/workflows/OpenWRT%20IMMUNITY
%20MONITORING%20CI%20Build/badge.svg?branch=master
   :target: https://github.com/edge-servers/openwrt-immunity-monitoring/actions?query=OpenWRT+IMMUNITY
+MONITORING+CI+Build%22
   :alt: CI build status

.. image:: https://coveralls.io/repos/github/immunity/openwrt-immunity-monitoring/badge.svg
   :target: https://coveralls.io/github/immunity/openwrt-immunity-monitoring
   :alt: Test Coverage

.. image:: http://img.shields.io/github/release/immunity/openwrt-immunity-monitoring.svg
   :target: https://github.com/edge-servers/openwrt-immunity-monitoring/releases

.. image:: https://img.shields.io/gitter/room/nwjs/nw.js.svg?style=flat-square
   :target: https://gitter.im/immunity/general
   :alt: support chat

------------

The `Immunity Monitoring <https://github.com/edge-servers/immunity-monitoring>`_ agent
for `OpenWRT <https://openwrt.org/>`_.

**Want to help Immunity?** `Find out how to help us grow here
<http://immunity.io/docs/general/help-us.html>`_.

.. image:: http://netjsonconfig.immunity.org/en/latest/_images/immunity.org.svg
  :target: http://immunity.org

.. contents:: **Table of Contents**:
 :backlinks: none
 :depth: 3

Install pre-compiled packages
-----------------------------

First run:

.. code-block:: shell

    opkg update

Then install the ``netjson-monitoring`` and ``immunity-monitoring`` packages from our
`latest builds <https://downloads.immunity.io/?prefix=immunity-monitoring/latest/>`_:

.. code-block:: shell

    cd /tmp
    wget <URL>
    opkg install ./<file-just-downloaded>

Where ``<URL>`` is the URL of the pre-compiled package.

For a list of the latest built images, take a look at
`downloads.immunity.io <https://downloads.immunity.io/?prefix=immunity-monitoring/>`_.

**If you need to compile the package yourself**, see
`Compiling immunity-monitoring <#compiling-openwrt-immunity-monitoring>`_.

Once installed *immunity-monitoring* needs to be configured
(see `Configuration options <#configuration-options>`_)
and then started with:

.. code-block:: shell

    /etc/init.d/immunity-monitoring restart

To ensure the agent is working correctly find out how to perform debugging in
the `Debugging <#debugging>`_ section.

Configuration options
---------------------

UCI configuration options must go in ``/etc/config/immunity-monitoring``.

- ``monitored_interfaces``: interfaces that needs to be monitored, defaults to ``*`` for all interfaces.
- ``interval``: the periodic interval in seconds at which the agent sends data to the server, defaults to ``300``.
- ``verbose_mode``: can be enabled (set to ``1``) to ease `debugging <#debugging>`__ in case of issues, defaults to ``0`` (disabled).
- ``required_memory``: available memory required to save data temporarily, defaults to ``0.05`` (5 percent).
- ``max_retries``: maximum number of retries in case of failures to send data to server in case of failure, defaults to ``5`` retries.
- ``bootup_delay``: maximum value in seconds of a random delay after bootup, defaults to ``10``, see `Bootup Delay`_

In case, `maximum retries are reached <#send-mode>`_, agent will try sending data again in next cycle.

Collecting vs Sending
---------------------

We use two procd services in `monitoring agent <https://github.com/edge-servers/openwrt-immunity-monitoring/blob/master/openwrt-immunity-monitoring/files/monitoring.agent>`_, one for collecting the data and other for sending the data.

This helps handle failure in sending the data in more flexible way. Old data saved during network connectivity issues can be sent while new data is being collected. If old data has piled up and takes several minutes to be uploaded, new data will be collected without waiting for the sending to complete.

Monitoring agent uses two different modes to handle this, ``send`` and ``collect``.

Collect Mode
~~~~~~~~~~~~

If immunity-monitoring agent is called with this mode, then the agent will keep charge of collecting and saving data.

Agent will periodically check if enough memory is available. If true, data will be collected and saved in temporary storage with the timestamp (in UTC timezone).

Once the data is saved, a signal will be sent to the other agent to ensure data is sent as soon as it is collected.

**Note:** Date and time on device should be set correctly. Otherwise, data will be saved with wrong timestamp in timeseries database.

Send Mode
~~~~~~~~~

If immunity-monitoring agent is called with this mode, then the agent will keep charge of sending data.

Agent will check if any data file is available in temporary storage.

If there is no data file, the agent will sleep for the time interval and check for the data file again. This will be continued until a data file is found.
If a signal is received from the other agent, then the sleep will be interrupted and agent will start sending data.

If agent fails to send data to the server, a randomized backoff (between 2 and 15 seconds) will be used to retry until `max_retries` is reached.
If all attempts of sending data failed, the agent will try to send data in the next cycle.

If data is sent successfully, then the data file will be deleted and agent will look for another file.

**SIGUSR1** signals are used to instantly send the data when collected. However, the service will keep trying
to send data periodically.

Bootup Delay
------------

The option ``bootup_delay`` is used to delay the initialization of the agent
for a random amount of seconds after the device boots.

The value specified in this option represents the maximum value of the range
of possible random values, the minimum value being ``0``.

The default value of this option is 10, meaning that the initialization of
the agent will be delayed for a random number of seconds, this random number
being comprised between ``0`` and ``10``.

This feature is used to spread the load on the Immunity server when a
large amount of devices boot up at the same time after a blackout.

Large Immunity installations may want to increase this value.

Compiling immunity-monitoring
-----------------------------

This repository ships 2 OpenWrt packages:

- **netjson-monitoring**: provides
  `NetJSON DeviceMonitoring
  <https://netjson.org/docs/what.html#devicemonitoring>`_ output
- **immunity-monitoring**: daemon which collects and sends
  `NetJSON DeviceMonitoring
  <https://netjson.org/docs/what.html#devicemonitoring>`_ data to
  `Immunity Monitoring
  <https://github.com/edge-servers/immunity-monitoring>`_
  It depends on **netjson-monitoring** and
  `immunity-config
  <https://github.com/edge-servers/immunity-config>`_

The following procedure illustrates how to compile *immunity-monitoring*, *netjson-monitoring* and their dependencies:

.. code-block:: shell

    git clone https://git.openwrt.org/openwrt/openwrt.git
    cd openwrt
    git checkout <openwrt-branch>

    # configure feeds
    echo "src-git immunity_config https://github.com/edge-servers/immunity-config.git" > feeds.conf
    echo "src-git immunity_monitoring https://github.com/edge-servers/openwrt-immunity-monitoring.git" >> feeds.conf
    cat feeds.conf.default >> feeds.conf
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    echo "CONFIG_PACKAGE_netjson-monitoring=y" >> .config
    echo "CONFIG_PACKAGE_immunity-monitoring=y" >> .config
    make defconfig
    make tools/install
    make toolchain/install
    make package/immunity-monitoring/compile

The compiled packages will go in ``bin/packages/*/immunity``.

Alternatively, you can configure your build interactively with ``make menuconfig``, in this case
you will need to select the *immunity-monitoring* and *netjson-monitoring* by going to ``Administration > admin > immunity``:

.. code-block:: shell

    git clone https://git.openwrt.org/openwrt/openwrt.git
    cd openwrt
    git checkout <openwrt-branch>

    # configure feeds
    echo "src-git immunity_config https://github.com/edge-servers/immunity-config.git" > feeds.conf
    echo "src-git immunity_monitoring https://github.com/edge-servers/openwrt-immunity-monitoring.git" >> feeds.conf
    cat feeds.conf.default >> feeds.conf
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    make menuconfig
    # go to Administration > admin > immunity and select the packages you need interactively
    make tools/install
    make toolchain/install
    make package/immunity-monitoring/compile

Debugging
---------

Debugging the *immunity-monitoring package* can be easily done by using
the ``logread`` command::

    logread | grep immunity-monitoring

In case of any issue, you can enable `verbose_mode <#configuration-options>`__.

If you are in that doubt immunity-monitoring is running at all or not, you can check with::

    ps | grep immunity-monitoring

You should see something like::

    2712 root      1224 S    /bin/sh /usr/sbin/immunity-monitoring --interval 300 --monitored_interfaces ...
    2713 root      1224 S    /bin/sh /usr/sbin/immunity-monitoring --url http://192.168.1.195:8000 ...

You can inspect the version of immunity-monitoring currently installed with::

    immunity-monitoring --version

Quality Assurance Checks
------------------------

We use `LuaFormatter <https://luarocks.org/modules/tammela/luaformatter>`_
and `shfmt <https://github.com/mvdan/sh#shfmt>`_ to format lua files and
shell scripts respectively.

Once they are installed, you can format all files by::

    ./qa-format

Run quality assurance tests with::

    #install immunity-utils QA tools first
    pip install immunity-utils[qa]

    #run QA checks before committing code
    ./run-qa-checks

Run tests
---------

To run the unit tests, you must install the required dependencies first;
to do this, you can take
a look at the
`install-dev.sh
<https://github.com/edge-servers/immunity-config/blob/master/install-dev.sh>`_
script.

Install test requirements::

    sudo ./install-dev.sh

You can run all unit tests by launching the dedicated script::

    ./runtests

Alternatively, you can run specific tests, e.g.::

    cd openwrt-immunity-monitoring/tests/
    lua test_utils.lua -v

Contributing
------------

Please read the `Immunity contributing guidelines
<http://immunity.io/docs/developer/contributing.html>`_.

Changelog
---------

See `CHANGELOG <https://github.com/edge-servers/openwrt-immunity-monitoring/blob/master/CHANGELOG.rst>`_.

License
-------

See `LICENSE <https://github.com/edge-servers/openwrt-immunity-monitoring/blob/master/LICENSE>`_.

Support
-------

See `Immunity Support Channels <http://immunity.org/support.html>`_.
