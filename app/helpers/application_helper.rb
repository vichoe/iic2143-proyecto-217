module ApplicationHelper
  def avatar_for(user, size: 32)
    style = "width: #{size}px; height: #{size}px; border-radius: 50%; vertical-align: middle;"

    if user.avatar.attached?
      image_tag user.avatar, alt: "Foto de #{user.name}", style: "#{style} object-fit: cover;"
    else
      tag.span user.name.first.upcase,
               style: "#{style} display: inline-flex; align-items: center; justify-content: center; background: #ccc;"
    end
  end
end