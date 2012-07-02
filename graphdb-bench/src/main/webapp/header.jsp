<html>
<head>
	<title><%= (jsp_title == null ? "" : jsp_title + " - ") %>GraphDB Benchmark Web Interface</title>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
	<meta name="description" content="GraphDB Benchmark Web Interface" />
<%
	if (!jsp_allow_cache) {
		%>	<meta http-equiv="cache-control" content="no-store" /><%;
		%>	<meta http-equiv="pragma" content="no-cache" /><%;
		%>	<meta http-equiv="expires" content="-1" /><%;
	}
%>
	<link rel="stylesheet" type="text/css" href="/style.css" media="screen" />
</head>
<body<%= jsp_body == null ? "" : " " + jsp_body %>>
	<div id="header">
		<h1>GraphDB Benchmark Web Interface</h1>
	</div>
	
	<div id="container_outer">
		<div id="menu">
			<ul>
				<% if (!jsp_page.equals("index")) { %>
					<li><a href="index.jsp">Home</a></li>
				<% } else { %>
					<li><p>Home</p></li>
				<% } %>
				<% if (!jsp_page.equals("addjob")) { %>
					<li><a href="addjob.jsp">Add a Job</a></li>
				<% } else { %>
					<li><p>Add a Job</p></li>
				<% } %>
			</ul>
		</div>
	
		<div id="content">
			<div id="content_inner">

			<!-- Content Begin -->
