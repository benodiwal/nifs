defmodule Demo do
  def run(sender, recipient, amount), do: Simulation.run_demo(sender, recipient, amount)
  def help, do: Simulation.print_usage()
end
