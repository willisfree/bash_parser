#include "Post.h"

const std::string Post::DescrLit::url = "Подробнее: ";
const std::string Post::DescrLit::title = "Требования: ";
const std::string Post::DescrLit::body = "Описание: ";
const std::string Post::DescrLit::price = "Оплата: ";

std::ostream& operator<<(std::ostream& os, const Post& post)
{
//return os << "url: " << post.url << "\ntitle: " << post.title << "\nbody: " << post.body << "\nprice: " << post.price;
//
        return os << Post::DescrLit::url << post.url << "\n"
                << Post::DescrLit::title << post.title << "\n"
                << Post::DescrLit::body  << post.body << "\n"
                << Post::DescrLit::price << post.price;
}
