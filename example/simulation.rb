# frozen_string_literal: true

require 'classic_bandit'
require 'gnuplot'

bandits = {
  "UCB1" => ClassicBandit::Ucb1.new(arms: [
      ClassicBandit::Arm.new(id: 0, trials: 1000, successes: 120),
      ClassicBandit::Arm.new(id: 1, trials: 1000, successes: 110),
      ClassicBandit::Arm.new(id: 2, trials: 1000, successes: 100),
  ]),
  "Thompson sampling" => ClassicBandit::ThompsonSampling.new(arms: [
      ClassicBandit::Arm.new(id: 0, trials: 1000, successes: 120),
      ClassicBandit::Arm.new(id: 1, trials: 1000, successes: 110),
      ClassicBandit::Arm.new(id: 2, trials: 1000, successes: 100),
  ])
}

arm0_counts = Hash.new(0)
arm0_probs = {}
bandits.keys.each { |key| arm0_probs[key] = [] }
x_values = []

10000.times.each do |i|
  bandits.each do |key, bandit|
    # 最初の500回はランダム
    if i < 500
      arm = bandit.arms.sample
    else
      arm = bandit.select_arm
    end
    reward = rand <= arm.mean_reward ? 1 : 0
    bandit.update(arm, reward)

    if arm.id == 0
      arm0_counts[key] += 1
    end

    arm0_prob = arm0_counts[key].to_f / (i + 1)
    arm0_probs[key] << arm0_prob
  end

  x_values << i + 1
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title  "Bandit Selection Probability"
    plot.xlabel "Iterations"
    plot.ylabel "Probability"
    
    # y軸の範囲を0-1に設定
    plot.yrange "[0:1]"
    
    # グリッドを表示
    plot.set "grid"
    
    # 線のスタイルを設定
    plot.set "style line 1 linecolor rgb '#0060ad' linewidth 2"
    plot.set "style line 2 linecolor rgb '#dd181f' linewidth 2"
    
    # 各アルゴリズムのデータをプロット
    colors = ["#0060ad", "#dd181f"]
    bandits.each_with_index do |(key, _), index|
      plot.data << Gnuplot::DataSet.new([x_values, arm0_probs[key]]) do |ds|
        ds.with = "lines"
        ds.linewidth = 2
        ds.linecolor = "rgb '#{colors[index]}'"
        ds.title = key.to_s
      end
    end
  end
end