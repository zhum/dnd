module AppHelpers
  def t(x)
    I18n.t(x)
  end

  def l(x)
    I18n.l(x)
  end

  def overForm3(f1, f2, f3, arg = '')
    f = <<-FORM
    <form class="mui--text-center">
      <a class="dnd-btn dnd-btn--primary" href="#" onclick="#{f1}('#{arg}');xover();">+</a>
      <a class="dnd-btn dnd-btn--primary" href="#" onclick="#{f2}('#{arg}');xover();">-</a>
      <input type="text" width="3" id="over_value"></input>
      <a class="dnd-btn dnd-btn--primary" href="#" onclick="#{f3}('#{arg}');xover();">OK</a>
    </form>
    FORM
    Regexp.escape f
  end

  def base_url
    "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end
