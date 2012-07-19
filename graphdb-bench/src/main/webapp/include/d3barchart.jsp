			
<script language="JavaScript">
	<!-- Begin
	
	var chart_inner_height = 420;
	var chart_margin = 10;
	
	var padding_left = 100;
	var padding_right = 300;
	var padding_top = 50;
	var padding_bottom = 150;
	
	var bar_width = 20;
	var bar_colors = d3.scale.category10();
	var bars_margin = 10;
	
	var ylabel_from_chart_margin = 40;
		
	var legend_padding_left = 10;
	var legend_padding_top = 10;
	var legend_bar_padding_right = 4;
	var legend_bar_width = 2 * bar_width;
	var legend_bar_height = bar_width;
	var legend_vertical_spacing = 2;
	
	d3.csv('<%= d3_source %>', function(data) {
		
		data.forEach(function(d) {
			<%= d3_foreach %>;
			d.mean = (+d.mean) / 1000000.0;			// convert to ms
			d.stdev = (+d.stdev) / 1000000.0;		// convert to ms
		});
		
		data = data.filter(function(d) {
			return <%= d3_filter %>;
		});
		
		var labels = data.map(function(d) { return d.label; });
		
		var chart = d3.select(".<%= d3_attach %>").append("svg")
					  .attr("class", "chart")
					  .attr("width",  bar_width * data.length + padding_left + padding_right)
					  .attr("height", chart_inner_height + padding_top + padding_bottom)
					  .append("g")
					  	.attr("transform", "translate(" + padding_left + ", " + padding_top + ")");
		
		var y = d3.scale.linear()
				  .domain([0, 1.1 * d3.max(data, function(d) { return d.mean; })])
				  .range([chart_inner_height, 0]);
		
		var x = d3.scale.ordinal()
				  .domain(labels)
				  .rangeBands([0, bar_width * data.length]);


		// The vertical ruler (ticks) and the axis
		
		chart.selectAll("line")
			 .data(y.ticks(10))
			 .enter().append("line")
			 .attr("x1", -bars_margin)
			 .attr("x2", data.length * bar_width + bars_margin)
			 .attr("y1", y)
			 .attr("y2", y)
			 .style("stroke", "#ccc");
		
		chart.selectAll(".rule")
			 .data(y.ticks(10))
			 .enter().append("text")
			 .attr("class", "rule")
			 .attr("x", -chart_margin-bars_margin)
			 .attr("y", y)
			 .attr("dx", 0)
			 .attr("dy", ".35em")
			 .attr("text-anchor", "end")
			 .text(String);
		
		chart.append("line")
			 .attr("x1", -bars_margin)
			 .attr("y1", 0)
			 .attr("x2", -bars_margin)
			 .attr("y2", chart_inner_height)
			 .style("stroke", "#000");
			 
		chart.append("text")
			 .attr("x", 0)
			 .attr("y", 0)
			 .attr("dx", 0)
			 .attr("dy", 0)
			 .attr("text-anchor", "middle")
			 .attr("transform", "translate("
			 	+ (-bars_margin*2 - ylabel_from_chart_margin) + ", "
			 	+ (chart_inner_height/2)  + "), rotate(-90)")
			 .text("<%= d3_ylabel %>");
		
		
		<%
			// Group labels and legend
			
			// TODO Bars within a group need different colors + we need a legend
			
			if (d3_group_label_function == null) {
				d3_group_label_function = "return d." + d3_group_by;
			}
			
			if (d3_group_by != null) {
				%>
				
					// Get the groups and the categories 
					
					var group_lengths = [];
					var group_columns = [];
					var group_offsets = [];
					var categories = [];
					
					var __last_group_column = "";
					var __last_group_length = -1;
					
					var group_label_function = function(d, i) {
						<%= d3_group_label_function %>
					};
					
					var category_label_function = function(d, i) {
						<%= d3_category_label_function %>
					};
					
					data.forEach(function(d, i) {
					
						var g = d.<%= d3_group_by %>;
						if (g != __last_group_column) {
							if (__last_group_length > 0) {
								group_columns.push(__last_group_column)
								group_lengths.push(__last_group_length)
							}
							if (__last_group_length == -1) {
								group_offsets.push(0);
							}
							else {
								group_offsets.push(group_offsets[group_offsets.length-1] + __last_group_length);
							}
							__last_group_column = g;
							__last_group_length = 0;
						}
						__last_group_length++;
						
						if (g != "" && g.indexOf("----") != 0) {
							var c = category_label_function(d, i);
							if (categories.indexOf(c) < 0) categories.push(c);
						}
					});
					
					if (__last_group_length > 0) {
						group_columns.push(__last_group_column)
						group_lengths.push(__last_group_length)
					}
					
					
					// Group labels
					
					for (var i = 0; i < group_columns.length; i++) {
						if (group_columns[i] == "" || group_columns[i].indexOf("----") == 0) continue;
						var p = group_offsets[i] + 0.5 * group_lengths[i] - 0.5;
						
						chart.append("text")
						 .attr("x", 0)
						 .attr("y", 0)
						 .attr("dx", 0)
						 .attr("dy", ".35em") // vertical-align: middle
						 .attr("transform", "translate("
						 	+ (x.rangeBand() * p + x.rangeBand() / 2) + ", "
						 	+ (chart_inner_height + chart_margin)  + "), rotate(45)")
						 .text(group_label_function(data[group_offsets[i]], group_offsets[i]));
					}
					
					
					// Legend
					
					for (var i = 0; i < categories.length; i++) {
					
						chart.append("rect")
							 .attr("x", bar_width * data.length + bars_margin + chart_margin + legend_padding_left)
							 .attr("y", i * (legend_bar_height + legend_vertical_spacing) + legend_padding_top)
							 .attr("width", legend_bar_width)
							 .attr("height", legend_bar_height)
							 .style("fill", bar_colors(i));
					
						chart.append("text")
							 .attr("x", bar_width * data.length + bars_margin + chart_margin
							 			+ legend_padding_left + legend_bar_width + legend_bar_padding_right)
							 .attr("y", (i + 0.5) * (legend_bar_height + legend_vertical_spacing) + legend_padding_top)
							 .attr("dx", 0)
						 	 .attr("dy", ".35em") // vertical-align: middle
							 .text(categories[i]);
					}
				<%
			}
		%>
		
		
		// Data and labels
				  
		chart.selectAll("bars_rect")
			 .data(data)
			 .enter().append("rect")
			 .attr("x", function(d, i) { return i * x.rangeBand(); })
			 .attr("y", function(d, i) { return y(d.mean); })
			<% if (d3_group_by != null) { %>
				.style("fill", function(d, i) {
					var c = category_label_function(d, i);
					var index = categories.indexOf(c);
					return index < 0 ? "black" : bar_colors(index);
				})
			<% } %>
			 .attr("width", x.rangeBand())
			 .attr("height", function(d, i) { return chart_inner_height - y(d.mean); });
			 
		data.forEach(function(d, i) {
		
			if (d.label.indexOf("----") == 0) return;
		
			<%
				if (d3_group_by == null) {
					%>
						chart.append("text")
						 .attr("x", 0)
						 .attr("y", 0)
						 .attr("dx", 0) // padding-right
						 .attr("dy", ".35em") // vertical-align: middle
						 .attr("transform", "translate("
						 	+ (x.rangeBand() * i + x.rangeBand() / 2) + ", "
						 	+ (chart_inner_height + chart_margin)  + "), rotate(45)")
						 .text(d.label);
					<%
				}
			%>
				 
			chart.append("text")
			 .attr("x", 0)
			 .attr("y", 0)
			 .attr("dx", 0)
			 .attr("dy", ".35em") // vertical-align: middle
			 .attr("transform", "translate("
			 	+ (x.rangeBand() * i + x.rangeBand() / 2) + ", "
			 	+ (y(d.mean) - 10)  + "), rotate(-90)")
			 .text("" + d.mean.toFixed(3) + " ms");
		});


		// Zero axis line
		
		chart.append("line")
			 .attr("x1", -bars_margin)
			 .attr("y1", chart_inner_height)
			 .attr("x2", bar_width * data.length + bars_margin)
			 .attr("y2", chart_inner_height)
			 .style("stroke", "#000");
	});
	
	//  End -->
</script>
