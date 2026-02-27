Jekyll::Hooks.register :documents, :pre_render do |doc|
  doc.content.gsub!(/```mermaid\n(.*?)```\n/m, '<div class="mermaid">\1</div>')
end
