header = """
<html>
<head>
  <title>RPi Zer0 WiFi Config</title>
  <meta name="viewport" content="initial-scale=1, maximum-scale=1">
</head>
<body>
  <h1>RPi Zer0 Wifi Config</h1>
"""

GET_body = """
  <form method="POST" action="/">

    <table>
      <tr>
        <td>
          <label for"ssid">Network Name:</label>
        </td>
        <td>
          <select style="width:100%;" name="ssid" id="ssid">
"""

GET_option = """
            <option value="{0}">{1}</option>
"""

GET_footer = """
          </select>
        </td>
        <td>
          <input type="button" value="Refresh" onClick="history.go(0)" />
        </td>
      </tr>
      <tr>
        <td>
          <label for="password">Password:</label>
        </td>
        <td>
          <input style="width:100%;" type="password" id="password" name="password" />
        </td>
        <td></td>
      </tr>
      <tr>
        <td colspan="2">
          <input type="submit" value="Reboot and Connect" />
        </td>
      </tr>
    </table>
  </form>
</body>
</html>
"""

POST_body = """
  <p>Success, rebooting and attempting to connect to the network: {0}</p>
</body>
</html>
"""