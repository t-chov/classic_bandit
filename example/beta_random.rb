# frozen_string_literal: true

require "gnuplot"

def gamma_random(alpha)
  return gamma_random(alpha + 1) * rand**(1.0 / alpha) if alpha < 1

  # Marsaglia-Tsang method
  d = alpha - 1.0 / 3
  c = 1.0 / Math.sqrt(9 * d)

  loop do
    z = normal_random
    v = (1 + c * z)**3
    u = rand

    return d * v if z > -1.0 / c && Math.log(u) < 0.5 * z * z + d * (1 - v + Math.log(v))
  end
end

def normal_random
  r = Math.sqrt(-2 * Math.log(rand))
  theta = 2 * Math::PI * rand
  r * Math.cos(theta)
end

def beta_function(alpha, beta)
  gamma_alpha = Math.lgamma(alpha)[0]
  gamma_beta = Math.lgamma(beta)[0]
  gamma_apb = Math.lgamma(alpha + beta)[0]
  Math.exp(gamma_alpha + gamma_beta - gamma_apb)
end

def beta_pdf(x, alpha, beta)
  return 0 if x <= 0 || x >= 1

  x**(alpha - 1) * (1 - x)**(beta - 1) / beta_function(alpha, beta)
end

data = Array.new(10_000) do
  x1 = gamma_random(41)
  x2 = gamma_random(61)
  x1 / (x1 + x2)
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title  "Beta distribution histogram"
    plot.xlabel "Value"
    plot.ylabel "Frequency"

    min_val = 0.0
    max_val = 1.0
    bin_count = 60.0
    bin_width = (max_val - min_val) / bin_count

    plot.xrange "[0:1]"
    total_count = data.length.to_f

    plot.set "style data histograms"
    plot.set "style fill solid 0.5"

    bins = Hash.new(0)
    bin_count.to_i.times.each { |i| bins[i * bin_width] = 0 }
    data.each { |v| bins[(v / bin_width).floor * bin_width] += 1 }
    bins.transform_values! { |v| v / (total_count * bin_width) }

    plot.data << Gnuplot::DataSet.new([bins.keys, bins.values]) do |ds|
      ds.with = "boxes"
      ds.title = "Empirical"
    end

    x_points = (0..100).map { |i| i / 100.0 }
    y_points = x_points.map { |x| beta_pdf(x, 41, 61) }
    plot.data << Gnuplot::DataSet.new([x_points, y_points]) do |ds|
      ds.with = "lines"
      ds.linewidth = 2
      ds.title = "Theoretical PDF"
    end
  end
end
