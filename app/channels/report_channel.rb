class ReportChannel < ApplicationCable::Channel
  def subscribed
    stream_from "report_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
