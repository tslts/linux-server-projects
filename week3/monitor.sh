#!/bin/bash
set -e

OUTPUT_DIR="/var/www/production/viikko3"
OUTPUT_FILE="$OUTPUT_DIR/index.html"
TEMP_FILE=$(mktemp "$OUTPUT_DIR/report.XXXXXX")

GENERATED_AT=$(date "+%Y-%m-%d %H:%M:%S %Z (%z)")
UPTIME_TEXT=$(uptime -p)
DISK_USAGE=$(df -P / | awk 'NR == 2 {print $5}')
DISK_NUM=${DISK_USAGE%\%}
MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_AVAILABLE=$(free -m | awk '/^Mem:/ {print $7}')

disk_status() {
    if [ "$1" -ge 90 ]; then
        echo "CRITICAL"
    elif [ "$1" -ge 80 ]; then
	echo "WARNING"
    else
        echo "OK"
    fi
}

if [[ -f "$OUTPUT_FILE" ]]; then
    cp -- "$OUTPUT_FILE" "$OUTPUT_FILE.bak"
fi
DISK_STATUS=$(disk_status "$DISK_NUM")

cat > "$TEMP_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Week 3 - Server Status Monitoring</title>
<style>
    * {
        box-sizing: border-box;
    }

    body {
        max-width: 850px;
        margin: 50px auto;
        padding: 0 24px;
        font-family: "Segoe UI", Arial, sans-serif;
        line-height: 1.7;
        background: #eef2f6;
        color: #263445;
    }

    header {
        padding: 38px;
        margin-bottom: 28px;
        background: #172b40;
        color: #ffffff;
        border-left: 5px solid #58a6a6;
        border-radius: 12px;
    }

    header h1 {
        margin: 0;
        font-size: 2rem;
        font-weight: 600;
    }

    header p {
        margin: 8px 0 0;
        color: #c3d2df;
    }
	.week-row {
	    display: flex;
	    align-items: center;
	    flex-wrap: wrap;
	    gap: 12px;
	    margin-top: 20px;
	}

	.week,
	.week-nav {
	    display: inline-flex;
	    align-items: center;
	    justify-content: center;
	    min-height: 40px;
	    min-width: 220px;
	    margin: 0;
	    padding: 5px 12px;
	    border: 1px solid #6c929e;
	    border-radius: 20px;
	    color: #b9d9d9;
	    font-size: 0.85rem;
	    line-height: 1.3;
	}

	.week {
	    white-space: nowrap;
	}

	.week-nav {
	    gap: 8px;
	}

	.week-nav label {
	    display: flex;
	    align-items: center;
	    align-self: center;
	    margin-top: 0;
	    font-weight: 400;
	    line-height: 1.3;
	    color: #b9d9d9;
	    white-space: nowrap;
	}

	.week-nav select {
	    max-width: 170px;
	    padding: 4px 8px;
	    border: 1px solid #6c929e;
	    border-radius: 14px;
	    background: #172b40;
	    color: #ffffff;
	    font: inherit;
	    cursor: pointer;
	}

	.week-nav select option {
	    background: #172b40;
	    color: #ffffff;
	}
    section {
        padding: 26px 30px;
        margin-bottom: 20px;
        background: #ffffff;
        border: 1px solid #dce4eb;
        border-radius: 10px;
        box-shadow: 0 3px 12px rgba(25, 45, 65, 0.04);
    }

    h2 {
        margin: 0 0 12px;
        color: #245574;
        font-size: 1.2rem;
        font-weight: 600;
    }

    h2 span {
        margin-right: 8px;
        color: #70a5a5;
    }

    h3 {
        color: #245574;
        font-size: 1.05rem;
        font-weight: 600;
    }

    p {
        margin: 8px 0 14px;
    }

    .table-container {
        overflow-x: auto;
    }

    table {
        width: 100%;
        border-collapse: collapse;
    }

    th, td {
        padding: 12px;
        border-bottom: 1px solid #dce4eb;
        text-align: left;
    }

    thead {
        background: #e5eef4;
    }

    th[scope="row"] {
        width: 45%;
    }

    .ok {
        color: #187344;
        font-weight: 600;
    }

    .warning {
        color: #b42318;
        font-weight: 600;
    }

    .note {
        color: #526779;
        font-size: 0.95rem;
    }

    code {
        font-family: Consolas, monospace;
        overflow-wrap: anywhere;
    }

    a {
        color: #245574;
    }

    footer {
        padding: 20px 0;
        color: #8492a0;
        font-size: 0.85rem;
        text-align: center;
    }

    @media (max-width: 600px) {
        body {
            margin: 20px auto;
            padding: 0 14px;
        }

        header {
            padding: 24px 20px;
        }

        header h1 {
            font-size: 1.7rem;
        }

        section {
            padding: 22px 20px;
        }

        th, td {
            padding: 8px;
        }
    }
</style>
</head>
<body>
<header>
	<h1>My Linux Server</h1>
	<div class="week-row">
	    <span class="week">WEEK 03 · SERVER MONITORING</span>
	    <nav class="week-nav">
	        <label for="week-select">Select week:</label>
	        <select id="week-select" onchange="if (this.value) window.location.href = this.value;">
	            <option value="/">Week 1</option>
	            <option value="/viikko2">Week 2</option>
	            <option value="/viikko3/" selected>Week 3</option>
	        </select>
	    </nav>
</div>
</header>

    <section>
        <h2>Current server status</h2>
        <div class="table-container" style="margin-bottom: 15px">
            <table>
                <thead>
                    <tr><th>Information</th><th>Value</th></tr>
                </thead>
                <tbody>
                    <tr><th scope="row">Report generated</th><td>$GENERATED_AT</td></tr>
                    <tr><th scope="row">Server uptime</th><td>$UPTIME_TEXT</td></tr>
                    <tr><th scope="row">Root filesystem disk usage</th><td>$DISK_USAGE</td></tr>
                    <tr><th scope="row">Disk space status</th><td class="$(if [ "$DISK_STATUS" = "OK" ]; then echo ok; else echo warning; fi)">$DISK_STATUS</td></tr>
                    <tr><th scope="row">Total RAM</th><td>$MEM_TOTAL MiB</td></tr>
                    <tr><th scope="row">Available RAM</th><td>$MEM_AVAILABLE MiB</td></tr>
                </tbody>
            </table>
        </div>
        <p>Disk usage is <strong>OK</strong> below 80% and <strong>WARNING</strong> at 80%. At 90% <strong>CRITICAL</strong> is shown.</p>
        <p class="note">The report is scheduled to update once every 30 seconds. Reload the page to see the latest report.</p>
    </section>

    <section>
        <h2>Commands used</h2>
        <ul>
            <li><code>date</code> displays the date, time and time zone.</li>
            <li><code>uptime -p</code> displays how long the server has been running.</li>
            <li><code>df -P /</code> reports root filesystem usage; <code>awk</code> extracts the percentage.</li>
            <li><code>free -m</code> reports memory in MiB.</li>
	    <li><code>scp screenshot.jpg user@remote_host:/remote/directory/</code> was used to copy a file from a local to VM.</li>
        </ul>
    </section>

    <section>
        <h2>How the script works</h2>
        <p>The script stores command output in Bash variables using command substitution. The <code>disk_status</code> function uses an if statement to return OK when disk usage is below 80%, or WARNING at 80% and CRITICAL at 90%.</p>
        <p>The pipe symbol (<code>|</code>) passes the output of one command to another. For example, <code>df -P / | awk 'NR == 2 {print &#36;5}'</code> passes filesystem information to awk, which prints the usage percentage (fifth column) from the second row.</p>
        <p>The script writes a temporary HTML file and then replaces the report with the completed file.</p>
    </section>

    <section>
        <h2>Scheduling</h2>
        <p>Systemd-service updates report table every 30 seconds. Timer is set to start when virtual machine starts. First I created monitor.service which is automated with mentioned systemd timer.</p>
    </section>

    <section>
        <h2>Test results</h2>
        <h3>Syntax check and manual execution</h3>
        <p>With <code>bash -n monitor.sh</code> I checked the script syntax. At same time the script executed manually and verified the report in the browser by creating a new .html file - which you are viewing right now.</p>

        <h3>Disk space status tests</h3>
        <p>Test the function with 50%, 80% and 90% inputs. Record the actual results after testing.</p>
        <div class="table-container">
            <table>
                <thead>
                    <tr><th>Test input</th><th>Expected status</th><th>Actual status</th></tr>
                </thead>
                <tbody>
                    <tr><td>50%</td><td>OK</td><td>OK</td></tr>
                    <tr><td>80%</td><td>WARNING</td><td>WARNING</td></tr>
                    <tr><td>90%</td><td>CRITICAL</td><td>CRITICAL</td></tr>
                </tbody>
            </table>
        </div>
        <h3>Automatic updates</h3>
        <p>Record the report generation times from at least two consecutive updates.</p>
	<img src="/viikko3/alma.jpg" style="max-width: 100%; height: auto; border-radius: 5px;">
	<h3>Reboot test</h3>
        <p>Services started with virtual machine after rebooting.</p>
    </section>

    <section>
        <h2>What I learned</h2>
        <p>I found commands easy and familiar. Script made me scratch my head several times, since during this task I found it hard to focus on one problem at once. Also piping bash commands are new for me even though I have used Linux as my main OS for 3 years now. On top of that using results as variables generates many possibilities if I want to automate something within my own system. Systemd timer caused some serious headscratching and AI helped me to find solution: At .service file row ExecStart expected /bin/bash before the pointing route to automated script. Also this was my first time using SCP to transfer a file.</p>
    </section>

<footer>
    	<p>&copy; TVT26KMO Linux Server Project</p>
	<p><a href="https://github.com/tslts/linux-server-projects.git">↗ GitHub</a></p>
</footer>
</body>
</html>
EOF

mv -f -- "$TEMP_FILE" "$OUTPUT_FILE"

chmod 755 "$OUTPUT_DIR"
chmod 644 "$OUTPUT_FILE"
