			
<script language="JavaScript">
	<!-- Begin
	
	var char_inner_width = 420;
	var bar_height = 20;
	var padding_left = 300;
	var padding_right = 100;
	var padding_top = 20;
	var padding_bottom = 0;
	
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
					  .attr("width", char_inner_width + padding_left + padding_right)
					  .attr("height", bar_height * data.length + padding_top + padding_bottom)
					  .append("g")
					  	.attr("transform", "translate(" + padding_left + ", " + padding_top + ")");
		
		var x = d3.scale.linear()
				  .domain([0, d3.max(data, function(d) { return d.mean; })])
				  .range([0, char_inner_width]);
		
		var y = d3.scale.ordinal()
				  .domain(labels)
				  .rangeBands([0, bar_height * data.length]);


		// The horizontal ruler (ticks)
		
		chart.selectAll("line")
			 .data(x.ticks(10))
			 .enter().append("line")
			 .attr("x1", x)
			 .attr("x2", x)
			 .attr("y1", 0)
			 .attr("y2", data.length * bar_height)
			 .style("stroke", "#ccc");
		
		chart.selectAll(".rule")
			 .data(x.ticks(10))
			 .enter().append("text")
			 .attr("class", "rule")
			 .attr("x", x)
			 .attr("y", 0)
			 .attr("dy", -3)
			 .attr("text-anchor", "middle")
			 .text(String);
		
		
		// Data and labels
				  
		chart.selectAll("rect")
			 .data(data)
			 .enter().append("rect")
			 .attr("y", function(d, i) { return i * y.rangeBand(); })
			 .attr("width", function(d, i) { return x(d.mean); })
			 .attr("height", y.rangeBand());
			 
		chart.selectAll("labels")
			 .data(data)
			 .enter().append("text")
			 .attr("x", -8)
			 .attr("y", function(d, i) { return y.rangeBand() * i + y.rangeBand() / 2; })
			 .attr("dx", 0) // padding-right
			 .attr("dy", ".35em") // vertical-align: middle
			 .attr("text-anchor", "end") // text-align: right
			 .text(function(d, i) { return d.label; });
			 
		chart.selectAll("data_values")
			 .data(data)
			 .enter().append("text")
			 .attr("x", function(d, i) { return x(d.mean); })
			 .attr("y", function(d, i) { return y.rangeBand() * i + y.rangeBand() / 2; })
			 .attr("dx", 5) // padding-right
			 .attr("dy", ".35em") // vertical-align: middle
			 .text(function(d, i) { return "" + d.mean.toFixed(2) + " ms"; });


		// Zero axis line
		
		chart.append("line")
			 .attr("y1", 0)
			 .attr("y2", bar_height * data.length + padding_top)
			 .style("stroke", "#000");
	});
	
	//  End -->
</script>
