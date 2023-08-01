module Parsers
  class GoogleImage < Base
    IMAGE_SLIDER_CLASS = 'MiPcId'
    IMAGE_NAME_CLASS = 'kltat'
    IMAGE_EXTENSIONS_CLASS = 'ellip'
    IMAGE_LINK_CLASS = 'klitem'

    def initialize(file_path:)
      super
    end

    def call
      paintings_slider_elements_html = document.search(".appbar .#{IMAGE_SLIDER_CLASS}")
      images_script = document.css('script').find { |script| script.text.include?('setImagesSrc') && script.text.include?('data:image') }

      paintings_slider_elements_html.map { |image_html| as_image_record(image_html:, images_script:) }
                                    .map(&:to_h)
    end

    private

    def as_image_record(image_html:, images_script:)
      image = Image.new

      Image::ATTRIBUTES.each do |attribute|
        image.send("#{attribute}=", send(attribute, image_html: , images_script:))
      end

      image
    end

    def extensions(**args)
      extensions_text = args[:image_html].search("div.#{IMAGE_EXTENSIONS_CLASS}").first

      [extensions_text.content.strip] if extensions_text
    end

    # At the moment this image script parser is giving me incorrect result. I bet this is my poor regular expression.
    def image(**args)
      image_node = args[:image_html].search('img').first
      return unless image_node

      image_id = image_node.get_attribute('id')
      return unless image_id

      scanned_image_src = args[:images_script].content.scan(/ii=\['#{image_id}'\].*s='(.*)';var/)

      scanned_image_src.first.first unless scanned_image_src.empty?
    end

    def link(**args)
      link_node = args[:image_html].search("a.#{IMAGE_LINK_CLASS}").first
      link_node.get_attribute('href') if link_node
    end

    def name(**args)
      name_text = args[:image_html].search("div.#{IMAGE_NAME_CLASS}").first
      name_text.content.strip if name_text
    end
  end
end