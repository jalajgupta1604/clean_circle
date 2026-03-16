module ApplicationHelper
  include Pagy::Frontend

  def pickup_status_badge(status)
    colors = {
      "scheduled" => "bg-blue-100 text-blue-800",
      "in_progress" => "bg-yellow-100 text-yellow-800",
      "completed" => "bg-emerald-100 text-emerald-800",
      "missed" => "bg-red-100 text-red-800",
      "cancelled" => "bg-gray-100 text-gray-800"
    }
    css = colors[status] || "bg-gray-100 text-gray-800"
    content_tag(:span, status.titleize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{css}")
  end

  def subscription_status_badge(status)
    colors = {
      "active" => "bg-emerald-100 text-emerald-800",
      "paused" => "bg-yellow-100 text-yellow-800",
      "cancelled" => "bg-red-100 text-red-800",
      "expired" => "bg-gray-100 text-gray-800"
    }
    css = colors[status] || "bg-gray-100 text-gray-800"
    content_tag(:span, status.titleize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{css}")
  end

  def role_badge(role)
    colors = {
      "customer" => "bg-emerald-100 text-emerald-800",
      "agent" => "bg-blue-100 text-blue-800",
      "admin" => "bg-indigo-100 text-indigo-800"
    }
    css = colors[role] || "bg-gray-100 text-gray-800"
    content_tag(:span, role.titleize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{css}")
  end

  def format_currency(amount)
    "₹#{number_with_delimiter(amount.to_f.round(2))}"
  end
end
